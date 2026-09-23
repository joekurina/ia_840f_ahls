`timescale 1ns/1ps
// Actual donor DMA top, CSR manager, descriptor queue, mux and PIM slices.
// External endpoints are synthetic linear line-request models. Host-side WRAP
// encodings are retained as donor/PIM metadata, NOT generic AXI WRAP semantics.
// Synthetic external endpoints; no PIM host mapper, DDR model or hardware proof.
`include "ofs_plat_if.vh"
module dma_csr_admission_tb;
  import dma_pkg::*;
  logic clk=0;
  always #5 clk=~clk;
  logic reset_n=0;
  wire descriptor_fifo_rdack=dut.descriptor_fifo_rdack;
  bit h2d=1,selected_bank=0,isolate=0;
  int csr_writes=0,csr_reads=0;
  t_dma_descriptor descriptor;
  t_dma_csr_control control;
  t_dma_csr_status rd_status,wr_status,engine_status;
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) src();
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) dst();
  assign src.clk=clk;
  assign dst.clk=clk;
  assign src.reset_n=reset_n;
  assign dst.reset_n=reset_n;
  ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) host();
  ofs_plat_axi_mem_if #(`LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT) bank[2]();
  ofs_plat_axi_mem_lite_if #(.ADDR_WIDTH(16),.DATA_WIDTH(64),.RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(14)) mmio();
  assign host.clk=clk;assign host.reset_n=reset_n;
  assign mmio.clk=clk;assign mmio.reset_n=reset_n;
  for(genvar g=0;g<2;g++)begin
    assign bank[g].clk=clk;assign bank[g].reset_n=reset_n;
    assign bank[g].instance_number=g+10;
  end
  assign host.instance_number=9;assign mmio.instance_number=8;
  dma_top #(.NUM_LOCAL_MEM_BANKS(2),.DDR_BANK_ADDR_W(34),.HOST_ADDR_W(57)) dut(
    .mmio64_to_afu(mmio),.host_mem(host),.ddr_mem(bank));
  assign rd_status=dut.rd_src_status;
  assign wr_status=dut.wr_dest_status;
  assign engine_status=dut.dma_engine_status;

  // Continuous field-wise fixture wiring avoids transient defaults feeding back
  // through bidirectional interface combinational processes at time zero.
  assign src.aw='0;
  assign src.w='0;
  assign dst.ar='0;
  assign src.awvalid=0;
  assign src.wvalid=0;
  assign src.bready=0;
  assign dst.arvalid=0;
  assign dst.rready=0;
  assign src.ar.id=h2d?host.ar.id:(selected_bank?bank[1].ar.id:bank[0].ar.id);
  assign src.ar.addr=h2d?host.ar.addr:(selected_bank?bank[1].ar.addr:bank[0].ar.addr);
  assign src.ar.len=h2d?host.ar.len:(selected_bank?bank[1].ar.len:bank[0].ar.len);
  assign src.ar.size=h2d?host.ar.size:(selected_bank?bank[1].ar.size:bank[0].ar.size);
  assign src.ar.burst=h2d?host.ar.burst:(selected_bank?bank[1].ar.burst:bank[0].ar.burst);
  assign src.ar.lock=h2d?host.ar.lock:(selected_bank?bank[1].ar.lock:bank[0].ar.lock);
  assign src.ar.cache=h2d?host.ar.cache:(selected_bank?bank[1].ar.cache:bank[0].ar.cache);
  assign src.ar.prot=h2d?host.ar.prot:(selected_bank?bank[1].ar.prot:bank[0].ar.prot);
  assign src.ar.qos=h2d?host.ar.qos:(selected_bank?bank[1].ar.qos:bank[0].ar.qos);
  assign src.ar.region=h2d?host.ar.region:(selected_bank?bank[1].ar.region:bank[0].ar.region);
  assign src.ar.user=h2d?host.ar.user:(selected_bank?bank[1].ar.user:bank[0].ar.user);
  assign src.arvalid=h2d?host.arvalid:(selected_bank?bank[1].arvalid:bank[0].arvalid);
  assign src.rready=h2d?host.rready:(selected_bank?bank[1].rready:bank[0].rready);
  assign dst.aw.id=!h2d?host.aw.id:(selected_bank?bank[1].aw.id:bank[0].aw.id);
  assign dst.aw.addr=!h2d?host.aw.addr:(selected_bank?bank[1].aw.addr:bank[0].aw.addr);
  assign dst.aw.len=!h2d?host.aw.len:(selected_bank?bank[1].aw.len:bank[0].aw.len);
  assign dst.aw.size=!h2d?host.aw.size:(selected_bank?bank[1].aw.size:bank[0].aw.size);
  assign dst.aw.burst=!h2d?host.aw.burst:(selected_bank?bank[1].aw.burst:bank[0].aw.burst);
  assign dst.aw.lock=!h2d?host.aw.lock:(selected_bank?bank[1].aw.lock:bank[0].aw.lock);
  assign dst.aw.cache=!h2d?host.aw.cache:(selected_bank?bank[1].aw.cache:bank[0].aw.cache);
  assign dst.aw.prot=!h2d?host.aw.prot:(selected_bank?bank[1].aw.prot:bank[0].aw.prot);
  assign dst.aw.qos=!h2d?host.aw.qos:(selected_bank?bank[1].aw.qos:bank[0].aw.qos);
  assign dst.aw.region=!h2d?host.aw.region:(selected_bank?bank[1].aw.region:bank[0].aw.region);
  assign dst.aw.user=!h2d?host.aw.user:(selected_bank?bank[1].aw.user:bank[0].aw.user);
  assign dst.aw.atop=!h2d?host.aw.atop:(selected_bank?bank[1].aw.atop:bank[0].aw.atop);
  assign dst.awvalid=!h2d?host.awvalid:(selected_bank?bank[1].awvalid:bank[0].awvalid);
  assign dst.wvalid=!h2d?host.wvalid:(selected_bank?bank[1].wvalid:bank[0].wvalid);
  assign dst.w=!h2d?host.w:(selected_bank?bank[1].w:bank[0].w);
  assign dst.bready=!h2d?host.bready:(selected_bank?bank[1].bready:bank[0].bready);
  assign host.arready=h2d?src.arready:1'b1;
  assign host.rvalid=h2d?src.rvalid:1'b0;
  assign host.r=h2d?src.r:'0;
  assign host.awready=h2d?1'b1:dst.awready;
  assign host.wready=h2d?1'b1:dst.wready;
  assign host.bvalid=h2d?1'b0:dst.bvalid;
  assign host.b=h2d?'0:dst.b;
  assign bank[0].arready=(selected_bank==0)?(h2d?1'b1:src.arready):!(isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty);
  assign bank[0].awready=(selected_bank==0)?(h2d?dst.awready:1'b1):!(isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty);
  assign bank[0].wready=(selected_bank==0)?(h2d?dst.wready:1'b1):!(isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty);
  assign bank[0].rvalid=((selected_bank==0)&&!h2d)?src.rvalid:(isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty);
  assign bank[0].bvalid=((selected_bank==0)&&h2d)?dst.bvalid:(isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty);
  assign bank[0].r.data=((selected_bank==0)&&!h2d)?src.r.data:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?'1:'0);
  assign bank[0].r.id=((selected_bank==0)&&!h2d)?src.r.id:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?9'd7:'0);
  assign bank[0].r.resp=((selected_bank==0)&&!h2d)?src.r.resp:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?SLVERR:'0);
  assign bank[0].r.last=((selected_bank==0)&&!h2d)?src.r.last:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?1'b1:'0);
  assign bank[0].r.user=((selected_bank==0)&&!h2d)?src.r.user:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?'0:'0);
  assign bank[0].b.id=((selected_bank==0)&&h2d)?dst.b.id:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?9'd7:'0);
  assign bank[0].b.resp=((selected_bank==0)&&h2d)?dst.b.resp:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?DECERR:'0);
  assign bank[0].b.user=((selected_bank==0)&&h2d)?dst.b.user:((isolate&&selected_bank!=0&&dut.descriptor_fifo_not_empty)?'0:'0);
  assign bank[1].arready=(selected_bank==1)?(h2d?1'b1:src.arready):!(isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty);
  assign bank[1].awready=(selected_bank==1)?(h2d?dst.awready:1'b1):!(isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty);
  assign bank[1].wready=(selected_bank==1)?(h2d?dst.wready:1'b1):!(isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty);
  assign bank[1].rvalid=((selected_bank==1)&&!h2d)?src.rvalid:(isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty);
  assign bank[1].bvalid=((selected_bank==1)&&h2d)?dst.bvalid:(isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty);
  assign bank[1].r.data=((selected_bank==1)&&!h2d)?src.r.data:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?'1:'0);
  assign bank[1].r.id=((selected_bank==1)&&!h2d)?src.r.id:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?9'd7:'0);
  assign bank[1].r.resp=((selected_bank==1)&&!h2d)?src.r.resp:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?SLVERR:'0);
  assign bank[1].r.last=((selected_bank==1)&&!h2d)?src.r.last:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?1'b1:'0);
  assign bank[1].r.user=((selected_bank==1)&&!h2d)?src.r.user:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?'0:'0);
  assign bank[1].b.id=((selected_bank==1)&&h2d)?dst.b.id:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?9'd7:'0);
  assign bank[1].b.resp=((selected_bank==1)&&h2d)?dst.b.resp:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?DECERR:'0);
  assign bank[1].b.user=((selected_bank==1)&&h2d)?dst.b.user:((isolate&&selected_bank!=1&&dut.descriptor_fifo_not_empty)?'0:'0);


  int lengths[8]='{1,257,514,1024,513,63,256,769};
  int checks=0,cycles=0,cases_done=0,total_ar=0,total_aw=0,total_r=0,total_w=0,total_b=0;
  int success_cases=0,error_cases=0,held_cases=0,r_stalls=0,w_stalls=0,max_buffered=0;
  int high_source_cases=0,high_dest_cases=0,retired_since_reset=0;
  logic [511:0] memory_image[0:4095];

  task automatic require_ok(input bit cond,input string reason);
    checks++;
    if(!cond)$fatal(1,"DMA_ADMISSION_FAIL cycle=%0d %s",cycles,reason);
  endtask
  function automatic logic [511:0] payload(input logic [56:0] address,input int case_id);
    logic [511:0] d;
    for(int j=0;j<8;j++)d[j*64+:64]={7'b0,address}^(64'h9e3779b97f4a7c15*(j+1))^(64'hd1b54a32d192ed03*(case_id+1));
    return d;
  endfunction

  task automatic csr_write(input int offset,input logic[63:0] value);
    bit adone,wdone,bdone;
    adone=0;wdone=0;bdone=0;
    @(negedge clk);#1;mmio.aw='0;mmio.aw.addr=offset;mmio.aw.size=3;mmio.aw.id=3;
    mmio.w='0;mmio.w.data=value;mmio.w.strb='1;mmio.awvalid=1;mmio.wvalid=1;mmio.bready=1;
    for(int t=0;t<100&&!bdone;t++)begin
      @(posedge clk);
      if(mmio.awvalid&&mmio.awready)adone=1;
      if(mmio.wvalid&&mmio.wready)wdone=1;
      if(mmio.bvalid&&mmio.bready)begin
        require_ok(adone&&wdone&&mmio.b.resp==OKAY&&mmio.b.id==3,"CSR write response mismatch");bdone=1;
      end
      @(negedge clk);#1;mmio.awvalid=!adone;mmio.wvalid=!wdone;
    end
    require_ok(bdone,"CSR write watchdog");mmio.awvalid=0;mmio.wvalid=0;csr_writes++;
  endtask
  task automatic csr_read(input int offset,output logic[63:0] value);
    bit adone,rdone;
    adone=0;rdone=0;
    @(negedge clk);#1;mmio.ar='0;mmio.ar.addr=offset;mmio.ar.size=3;mmio.ar.id=5;mmio.arvalid=1;mmio.rready=1;
    for(int t=0;t<100&&!rdone;t++)begin
      @(posedge clk);
      if(mmio.arvalid&&mmio.arready)adone=1;
      if(mmio.rvalid&&mmio.rready)begin
        require_ok(adone&&mmio.r.resp==OKAY&&mmio.r.id==5,"CSR read response mismatch");value=mmio.r.data;rdone=1;
      end
      @(negedge clk);#1;mmio.arvalid=!adone;
    end
    require_ok(rdone,"CSR read watchdog");mmio.arvalid=0;csr_reads++;
  endtask


  int rejected_writes=0,rejected_reads=0,rejected_go=0,admission_checks=0,queue_accepts=0;
  int enqueues=0;
  bit admission_quiet=0;
  always @(posedge clk) if(reset_n)begin
    if(dut.wr_desc_fifo_if.wr_en)enqueues++;
    if(admission_quiet)begin
      require_ok(!dut.wr_desc_fifo_if.wr_en,"rejected request enqueued descriptor");
      require_ok(!host.arvalid&&!host.awvalid&&!host.wvalid &&
                 !bank[0].arvalid&&!bank[0].awvalid&&!bank[0].wvalid &&
                 !bank[1].arvalid&&!bank[1].awvalid&&!bank[1].wvalid,
                 "rejected request issued memory traffic");
    end
  end
  task automatic init_admission;
    admission_quiet=0;
    @(negedge clk);#1;reset_n=0;
    src.arready=0;src.rvalid=0;src.r='0;
    dst.awready=0;dst.wready=0;dst.bvalid=0;dst.b='0;
    repeat(5)@(posedge clk);
    @(negedge clk);#1;reset_n=1;
    repeat(3)@(posedge clk);
    @(negedge clk);#1;admission_quiet=1;
  endtask
  // Deliberately split AW/W arrival and stall B. Check ID/USER and response stability.
  task automatic write_checked(input int a,input logic[63:0] v,
      input logic[7:0] st,input int size,input logic[1:0] expected);
    bit adone,wdone,bdone;
    logic[mmio.T_B_WIDTH-1:0] saved_b;
    adone=0;wdone=0;bdone=0;
    @(negedge clk);#1;mmio.aw='0;mmio.aw.addr=a;mmio.aw.size=size;
    mmio.aw.id=7;mmio.aw.user=13;mmio.awvalid=1;mmio.wvalid=0;mmio.bready=0;
    for(int t=0;t<80&&!bdone;t++)begin
      if(t==4)begin mmio.w='0;mmio.w.data=v;mmio.w.strb=st;mmio.wvalid=1;end
      @(posedge clk);
      if(mmio.awvalid&&mmio.awready)adone=1;
      if(mmio.wvalid&&mmio.wready)wdone=1;
      if(mmio.bvalid)begin
        require_ok(adone&&wdone&&mmio.b.resp===expected&&mmio.b.id==7&&mmio.b.user==13,
            $sformatf("CSR reject/write a=%h expected=%0d actual=%0d",a,expected,mmio.b.resp));
        saved_b=mmio.b;
        repeat(3)begin @(posedge clk);require_ok(mmio.bvalid&&mmio.b===saved_b,"stalled B changed");end
        @(negedge clk);#1;mmio.bready=1;
        @(posedge clk);require_ok(mmio.bvalid,"lost B before accept");bdone=1;
      end
      @(negedge clk);#1;mmio.awvalid=!adone;mmio.wvalid=(t>=4)&&!wdone;
    end
    require_ok(bdone,"write_checked watchdog");mmio.awvalid=0;mmio.wvalid=0;
    if(expected!=OKAY)begin rejected_writes++;if(a==8*DMA_DESCRIPTOR_CONTROL)rejected_go++;end
    admission_checks++;
    repeat(2)@(posedge clk);
  endtask
  task automatic read_rejected(input int a,input int size);
    bit adone,rdone;
    logic[mmio.T_R_WIDTH-1:0] saved_r;
    adone=0;rdone=0;
    @(negedge clk);#1;mmio.ar='0;mmio.ar.addr=a;mmio.ar.size=size;
    mmio.ar.id=11;mmio.ar.user=17;mmio.arvalid=1;mmio.rready=0;
    for(int t=0;t<80&&!rdone;t++)begin
      @(posedge clk);
      if(mmio.arvalid&&mmio.arready)adone=1;
      if(mmio.rvalid)begin
        require_ok(adone&&mmio.r.resp===DECERR&&mmio.r.data===64'b0&&mmio.r.id==11&&mmio.r.user==17,"invalid read was not DECERR/zero");
        saved_r=mmio.r;
        repeat(3)begin @(posedge clk);require_ok(mmio.rvalid&&mmio.r===saved_r,"stalled R changed");end
        @(negedge clk);#1;mmio.rready=1;
        @(posedge clk);require_ok(mmio.rvalid,"lost R before accept");rdone=1;
      end
      @(negedge clk);#1;mmio.arvalid=!adone;
    end
    require_ok(rdone,"read_rejected watchdog");mmio.arvalid=0;rejected_reads++;admission_checks++;
  endtask
  task automatic prime(input logic[63:0] s=64'h100000000004000,
      input logic[63:0] d=64'h200008000,input logic[63:0] n=1);
    csr_write(8*DMA_SRC_ADDR,s);csr_write(8*DMA_DEST_ADDR,d);csr_write(8*DMA_LENGTH,n);
  endtask
  task automatic bad_field(input int a,input logic[63:0] value);
    logic[63:0] before_value,after_value;
    prime();csr_read(a,before_value);
    write_checked(a,value,8'hff,3,SLVERR);csr_read(a,after_value);
    require_ok(before_value===after_value,"failed field write changed CSR value");
    write_checked(8*DMA_DESCRIPTOR_CONTROL,64'h84000000,8'hff,3,SLVERR);
  endtask
  task automatic bad_descriptor(input logic[63:0] s,input logic[63:0] d,
      input logic[63:0] n,input logic[63:0] command=64'h84000000);
    prime(s,d,n);write_checked(8*DMA_DESCRIPTOR_CONTROL,command,8'hff,3,SLVERR);
  endtask
  task automatic admit_only(input logic[63:0] s,input logic[63:0] d,input logic[63:0] n,input logic[63:0] cmd);
    int before_count;
    init_admission();prime(s,d,n);before_count=enqueues;admission_quiet=0;
    write_checked(8*DMA_DESCRIPTOR_CONTROL,cmd,8'hff,3,OKAY);
    require_ok(enqueues==before_count+1,"valid boundary descriptor not enqueued once");
    queue_accepts++;
    // Only admission checked. No R/W transfers provided; fixture reset next.
  endtask
  task automatic run_admission;
    logic[63:0] v;
    int before_count;
    init_admission();prime();
    // Full byte-address decode, access size, byte enables and RO/unknown targets.
    write_checked(16'h128,64'hdead,8'hff,3,DECERR);
    csr_read(8*DMA_SRC_ADDR,v);require_ok(v==64'h100000000004000,"high alias changed source");
    write_checked(16'h2a,64'hdead,8'hff,3,DECERR);
    write_checked(16'h28,64'hdead,8'h0f,3,DECERR);
    write_checked(16'h28,64'hdead,8'h00,3,DECERR);
    write_checked(16'h28,64'hdead,8'hff,2,DECERR);
    write_checked(8*DMA_STATUS,64'hdead,8'hff,3,DECERR);
    write_checked(16'h98,64'hdead,8'hff,3,DECERR);
    read_rejected(16'h128,3);read_rejected(16'h2a,3);read_rejected(16'h28,2);read_rejected(16'h98,3);
    bad_field(8*DMA_SRC_ADDR,64'h8000000000004000);
    bad_field(8*DMA_DEST_ADDR,64'h0200000000008000);
    bad_field(8*DMA_LENGTH,0);bad_field(8*DMA_LENGTH,130817);
    bad_field(8*DMA_LENGTH,64'h100001);
    bad_descriptor(64'h4000,64'h8000,1,64'h80000000);
    bad_descriptor(64'h4000,64'h8000,1,64'h8c000000);
    bad_descriptor(64'h4000,64'h8000,1,64'h84000001);
    bad_descriptor(64'h4000,64'h8000,1,64'h94000000);
    bad_descriptor(64'h4000,64'h8000,1,64'h184000000);
    bad_descriptor(64'h4001,64'h8000,1);
    bad_descriptor(64'h4000,64'h8001,1);
    bad_descriptor(64'h4000,64'h800000000,1);
    bad_descriptor(64'h800000000,64'h8000,1,64'h88000000);
    bad_descriptor(64'h4000,64'h3ffffffc0,2);
    bad_descriptor(64'h7ffffffc0,64'h8000,2,64'h88000000);
    bad_descriptor(64'h1ffffffffffffc0,64'h8000,2);
    bad_descriptor(64'h4000,64'h1ffffffffffffc0,2,64'h88000000);
    // No fresh staging after a failed GO: retained values must not replay.
    write_checked(8*DMA_DESCRIPTOR_CONTROL,64'h84000000,8'hff,3,SLVERR);
    // Boundary admissions, not maximum-length data transfers.
    admit_only(64'h1ffffffffffffc0,64'h3ffffffc0,1,64'h84000000);
    admit_only(64'h7ffffffc0,64'h1ffffffffffffc0,1,64'h88000000);
    admit_only(64'h4000,64'h8000,130816,64'h84000000);
    // Fill actual queue against stalled endpoints; capacity includes its output stage.
    init_admission();admission_quiet=0;
    for(int n=0;n<24&&!dut.dma_csr_status.descriptor_fifo_full;n++)begin
      prime();before_count=enqueues;
      write_checked(8*DMA_DESCRIPTOR_CONTROL,64'h84000000,8'hff,3,OKAY);
      require_ok(enqueues==before_count+1,"accepted queue entry missing/duplicate");queue_accepts++;
    end
    require_ok(dut.dma_csr_status.descriptor_fifo_full,"did not fill descriptor FIFO");
    prime();before_count=enqueues;
    write_checked(8*DMA_DESCRIPTOR_CONTROL,64'h84000000,8'hff,3,SLVERR);
    require_ok(enqueues==before_count,"full queue accepted GO");
    init_admission();admission_quiet=0;
    $display("DMA_ADMISSION_GUARD_PASS checks=%0d rejected_writes=%0d rejected_reads=%0d rejected_go=%0d queue_accepts=%0d",admission_checks,rejected_writes,rejected_reads,rejected_go,queue_accepts);
  endtask

  task automatic run_case(input int cid,input int length);
    logic [56:0] sbase,dbase,qar[$],raddr,current_aw;
    logic [63:0] csr_value;
    int qlen[$];
    int ar_count,aw_count,r_count,w_count,b_count,enq_count,deq_count;
    int announced_rd,announced_wr,rburst_len,rbeat,rbursts,wbursts,wbeat;
    int phase,ar_age,aw_age,b_delay,quiet,terminal_quiet,acks,idx;
    int burst_count,expected_len;
    bit host_to_ddr,do_reset,expect_error,missing,active_r,hold_r;
    bit ar_stalled,aw_stalled,w_stalled,finished,success_seen,error_seen;
    logic [src.T_AR_WIDTH-1:0] old_ar;
    logic [src.T_R_WIDTH-1:0] old_r;
    logic [dst.T_AW_WIDTH-1:0] old_aw;
    logic [dst.T_W_WIDTH-1:0] old_w;
    host_to_ddr=(cid%2)==0;h2d=host_to_ddr;selected_bank=(cid/2)%2;
    sbase=host_to_ddr ? (57'h100000000000000|57'h400000000|57'h4000|cid*57'h10000) : 57'h200004000+cid*57'h10000;
    dbase=host_to_ddr ? 57'h200008000+cid*57'h10000 : (57'h80000000000000|57'h800000000|57'h8000|cid*57'h10000);
    if(host_to_ddr)high_source_cases++;else high_dest_cases++;
    do_reset=(cid==0);expect_error=0;missing=0;
    ar_count=0;aw_count=0;r_count=0;w_count=0;b_count=0;enq_count=0;deq_count=0;
    announced_rd=0;announced_wr=0;rburst_len=0;rbeat=0;rbursts=0;wbursts=0;wbeat=0;
    ar_age=0;aw_age=0;b_delay=0;quiet=0;terminal_quiet=0;acks=0;
    active_r=0;hold_r=0;ar_stalled=0;aw_stalled=0;w_stalled=0;
    finished=0;success_seen=0;error_seen=0;burst_count=(length+255)/256;
    for(int i=0;i<length;i++)memory_image[i]='x;
    @(negedge clk);#1;
    reset_n=!do_reset;descriptor='0;control='0;
    src.arready=0;src.rvalid=0;src.r='0;src.awready=0;src.wready=0;src.bvalid=0;src.b='0;src.instance_number=0;
    dst.arready=0;dst.rvalid=0;dst.r='0;dst.awready=0;dst.wready=0;dst.bvalid=0;dst.b='0;dst.instance_number=1;
    repeat(5)@(posedge clk);
    if(do_reset)retired_since_reset=0;
    @(negedge clk);#1;
    reset_n=1;descriptor.src_addr=sbase;descriptor.dest_addr=dbase;descriptor.length=length;
    descriptor.descriptor_control.mode=host_to_ddr?HOST_TO_DDR:DDR_TO_HOST;
    descriptor.descriptor_control.go=1;
    csr_write(8*DMA_SRC_ADDR,host_to_ddr?sbase:(sbase|(57'(selected_bank)<<34)));
    csr_write(8*DMA_DEST_ADDR,host_to_ddr?(dbase|(57'(selected_bank)<<34)):dbase);
    csr_write(8*DMA_LENGTH,length);
    csr_read(8*DMA_SRC_ADDR,csr_value);
    require_ok(csr_value===(host_to_ddr?{7'b0,sbase}:{7'b0,(sbase|(57'(selected_bank)<<34))}),"CSR source address lost bits");
    csr_write(8*DMA_DESCRIPTOR_CONTROL,{32'b0,descriptor.descriptor_control});

    for(phase=0;phase<50000&&!finished;phase++)begin
      @(negedge clk);#1;
      if(dut.descriptor_fifo_not_empty)begin
        if(selected_bank==0)begin
          require_ok(!bank[1].arvalid&&!bank[1].awvalid&&!bank[1].wvalid,"request leaked into inactive bank1");
          if(isolate)require_ok(!bank[1].rready&&!bank[1].bready,"inactive bank1 reply was consumed");
        end else begin
          require_ok(!bank[0].arvalid&&!bank[0].awvalid&&!bank[0].wvalid,"request leaked into inactive bank0");
          if(isolate)require_ok(!bank[0].rready&&!bank[0].bready,"inactive bank0 reply was consumed");
        end
      end
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
      end
      // Delayed in-order B replies, never before this model accepted WLAST.
      if(!dst.bvalid||dst.bready)begin
        dst.bvalid=0;dst.b='0;
        if(!missing&&b_count<wbursts&&b_delay==0)begin
          dst.bvalid=1;
          if(expect_error&&b_count==0)dst.b.resp=SLVERR;
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
        r_count++;total_r++;rbeat++;
        if(src.r.last)begin active_r=0;rbursts++;end
      end
      if(dut.dma_engine_inst.wr_fifo_if.wr_en)begin
        require_ok(dut.dma_engine_inst.wr_fifo_if.not_full,"enqueue into full real FIFO");
        require_ok(enq_count<r_count&&enq_count<length,"extra enqueue");
        require_ok(dut.dma_engine_inst.wr_fifo_if.wr_data[511:0]===payload(sbase+enq_count*64,cid),"reader/FIFO payload mismatch");
        require_ok(dut.dma_engine_inst.wr_fifo_if.wr_data[512]===((enq_count%256==255)||(enq_count==length-1)),"FIFO WLAST mismatch");
        require_ok(dut.dma_engine_inst.wr_fifo_if.wr_data[513]===(enq_count==length-1),"FIFO packet marker mismatch");
        enq_count++;
      end
      if(dut.dma_engine_inst.rd_fifo_if.rd_en)begin
        require_ok(dut.dma_engine_inst.rd_fifo_if.not_empty&&deq_count<enq_count,"invalid FIFO dequeue");
        require_ok(dut.dma_engine_inst.rd_fifo_if.rd_data[511:0]===payload(sbase+deq_count*64,cid),"real FIFO reordered/corrupted data");
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
      require_ok(r_count>=enq_count&&r_count-enq_count<=3,"reader enqueue pipeline mismatch");
      require_ok(deq_count>=w_count&&deq_count-w_count<=3,"writer output occupancy mismatch");
      if(r_count-w_count>max_buffered)max_buffered=r_count-w_count;
      if(descriptor_fifo_rdack)begin
        require_ok(!expect_error&&!missing,"failed descriptor retired");
        require_ok(r_count==length&&w_count==length&&b_count==burst_count&&enq_count==length&&deq_count==length,"premature descriptor retirement");
        require_ok(qar.size()==0&&!active_r&&!dut.dma_engine_inst.rd_fifo_if.not_empty&&!dut.dma_engine_inst.wr_fifo_if.wr_en&&!dst.wvalid,"descriptor retired before local pipe drained");
        acks++;require_ok(acks==1,"duplicate descriptor retirement");retired_since_reset++;success_seen=1;
        for(int i=0;i<length;i++)require_ok(memory_image[i]===payload(sbase+i*64,cid),"copied-back memory value mismatch");
      end
      if(wr_status.stopped_on_error)begin
        require_ok(expect_error&&w_count==length&&b_count==burst_count,"incorrect error stop");
        require_ok(wr_status.wr_rsp_err&&!descriptor_fifo_rdack&&wr_status.busy&&rd_status.busy,"error not held at descriptor boundary");error_seen=1;
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
      if(success_seen)require_ok(rd_status.descriptor_count==(retired_since_reset%16),"descriptor counter missed successful dequeue");
    end
    require_ok(finished,$sformatf("watchdog case=%0d AR=%0d R=%0d AW=%0d W=%0d B=%0d",cid,ar_count,r_count,aw_count,w_count,b_count));
    if(expect_error)begin require_ok(error_seen&&!success_seen,"error disposition missing");error_cases++;end
    else if(missing)begin require_ok(!success_seen&&!error_seen,"missing-response hold lost");held_cases++;end
    else begin require_ok(success_seen&&acks==1,"successful descriptor missing");success_cases++;end
    csr_read(8*DMA_STATUS,csr_value);
    require_ok(csr_value[31:28]==(retired_since_reset%16)&&!csr_value[0]&&csr_value[1],"CSR completion/count/queue status mismatch");
    cases_done++;
    $display("DMA_ADMISSION_CASE id=%0d mode=%0d length=%0d AR=%0d AW=%0d R=%0d W=%0d B=%0d retired=%0d error=%0d held=%0d source=%h destination=%h",cid,descriptor.descriptor_control.mode,length,ar_count,aw_count,r_count,w_count,b_count,acks,error_seen,missing,sbase,dbase);
  endtask
  initial begin
    descriptor='0;control='0;
    $display("DMA_ADMISSION_START time=%0t",$time);
    isolate=$test$plusargs("ISOLATE");
    mmio.ar='0;mmio.arvalid=0;mmio.rready=1;mmio.aw='0;mmio.awvalid=0;mmio.w='0;mmio.wvalid=0;mmio.bready=1;
    src.arready=0;src.rvalid=0;src.r='0;src.awready=0;src.wready=0;src.bvalid=0;src.b='0;src.instance_number=0;
    dst.arready=0;dst.rvalid=0;dst.r='0;dst.awready=0;dst.wready=0;dst.bvalid=0;dst.b='0;dst.instance_number=1;
    run_admission();
    for(int i=0;i<8;i++)run_case(i,lengths[i]);
    require_ok(success_cases==8&&error_cases==0&&held_cases==0&&r_stalls>0&&w_stalls>0&&max_buffered>=32,"coverage/classification incomplete");
    $display("DMA_ADMISSION_UNIT_PASS cases=%0d cycles=%0d checks=%0d AR=%0d AW=%0d R=%0d W=%0d B=%0d success=%0d errors=%0d held=%0d r_stalls=%0d w_stalls=%0d max_buffered=%0d high_source=%0d high_dest=%0d",cases_done,cycles,checks,total_ar,total_aw,total_r,total_w,total_b,success_cases,error_cases,held_cases,r_stalls,w_stalls,max_buffered,high_source_cases,high_dest_cases);
    $display("DMA_ADMISSION_CSR_COUNTS writes=%0d reads=%0d isolated=%0d",csr_writes,csr_reads,isolate);
    $finish;
  end
  initial begin #10000000;$fatal(1,"global engine watchdog");end
endmodule

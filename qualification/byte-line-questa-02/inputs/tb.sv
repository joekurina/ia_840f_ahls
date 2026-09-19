// TEST FIXTURE ONLY. Actual DUT and PIM interface are compiled from original paths.
`timescale 1ns/1ps
module tb;
  logic clk = 0;
  always #5 clk = ~clk;
  ofs_plat_avalon_mem_if #(.ADDR_WIDTH(16), .DATA_WIDTH(512),
    .BURST_CNT_WIDTH(7), .USER_WIDTH(8), .WAIT_REQUEST_ALLOWANCE(0)) b();
  ofs_plat_avalon_mem_if #(.ADDR_WIDTH(10), .DATA_WIDTH(512),
    .BURST_CNT_WIDTH(7), .USER_WIDTH(8), .WAIT_REQUEST_ALLOWANCE(0)) l();
  assign l.clk = clk;
  logic fault;
  ahls_avmm_byte_to_line dut(.byte_mem(b), .line_mem(l), .address_alignment_fault(fault));
  int scenarios = 0;
  int checks = 0;
  logic [511:0] observed [0:1023];
  logic [511:0] expected [0:1023];

  task automatic ck(input bit ok, input string what);
    checks++;
    if (!ok) $fatal(1, "FAIL scenario=%0d %s", scenarios, what);
  endtask

  // Each call is one fully checked cycle. Drive away from clock edges.
  // Expected alignment is checked on EVERY asserted cycle, including burst
  // continuation and deliberately malformed stalled cycles (negative stimuli).
  task automatic cycle(input string name, input bit rd, wr,
      input logic [15:0] addr, input logic [6:0] count,
      input logic [63:0] mask, input logic [511:0] data,
      input bit stall, rst, input logic [7:0] tag,
      input bit rv, wv, input logic [1:0] rr, wresp);
    bit bad, blocked;
    int idx;
    @(negedge clk); #1;
    b.read = rd; b.write = wr; b.address = addr;
    b.burstcount = count; b.byteenable = mask; b.writedata = data; b.user = tag;
    l.waitrequest = stall; l.reset_n = rst; l.instance_number = 32'h12345678;
    idx = int'(addr) / 64;
    l.readdata = observed[idx]; l.readdatavalid = rv;
    l.response = rr; l.readresponseuser = tag ^ 8'h96;
    l.writeresponsevalid = wv; l.writeresponse = wresp;
    l.writeresponseuser = tag ^ 8'h69;
    #1;
    bad = (rd || wr) && (int'(addr) % 64 != 0);
    blocked = stall || bad || !rst;
    ck(fault === bad, "per-cycle alignment fault");
    ck(b.waitrequest === blocked, "waitrequest/stall/reset");
    ck(l.read === (rd && !bad && rst), "read gate");
    ck(l.write === (wr && !bad && rst), "write gate");
    ck(l.address === 10'(idx), "byte to native beat address");
    ck(l.burstcount === count, "burstcount unchanged");
    ck(l.byteenable === mask, "byteenable unchanged");
    ck(l.writedata === data, "write data unchanged");
    ck(l.user === tag, "request user unchanged");
    ck(b.reset_n === rst && b.instance_number === 32'h12345678, "reset/instance wiring");
    ck(b.clk === clk, "clock low wiring");
    ck(b.readdatavalid === rv && b.readdata === expected[idx], "read response scoreboard");
    ck(b.response === rr && b.readresponseuser === (tag ^ 8'h96), "read status/user");
    ck(b.writeresponsevalid === wv && b.writeresponse === wresp &&
       b.writeresponseuser === (tag ^ 8'h69), "write response status/user");
    @(posedge clk); #1;
    ck(b.clk === clk, "clock high wiring");
    // Synthetic downstream storage is only a byte-mask forwarding oracle,
    // not a substitute DUT or a full Avalon memory/burst implementation.
    if (l.write && !l.waitrequest)
      for (int j=0; j<64; j++) if (l.byteenable[j])
        observed[l.address][8*j +: 8] = l.writedata[8*j +: 8];
    if (wr && !blocked)
      for (int j=0; j<64; j++) if (mask[j])
        expected[idx][8*j +: 8] = data[8*j +: 8];
    for (int j=0; j<1024; j++) ck(observed[j] === expected[j], "storage scoreboard");
    scenarios++;
    $display("CHECKED %0d %s", scenarios, name);
  endtask

  initial begin
    b.read=0; b.write=0; b.address=0; b.burstcount=1;
    b.byteenable='1; b.writedata=0; b.user=0;
    l.reset_n=0; l.waitrequest=0; l.instance_number=0;
    l.readdata=0; l.readdatavalid=0; l.response=0; l.readresponseuser=0;
    l.writeresponsevalid=0; l.writeresponse=0; l.writeresponseuser=0;
    for (int j=0;j<1024;j++) begin observed[j]=0; expected[j]=0; end
    cycle("reset read",1,0,16'h80,1,'1,0,0,0,1,0,0,0,0);
    cycle("reset write",0,1,16'h80,1,'1,'1,0,0,2,0,0,0,0);
    cycle("idle misaligned no fault",0,0,16'h81,1,'1,0,0,1,3,0,0,0,0);
    cycle("aligned full write",0,1,16'h80,1,'1,'1,0,1,4,0,0,0,0);
    cycle("partial write",0,1,16'h80,1,64'h5555555555555555,0,0,1,5,0,1,0,1);
    cycle("zero mask write",0,1,16'h80,1,0,'1,0,1,6,0,0,0,0);
    cycle("aligned read",1,0,16'h80,1,'1,0,0,1,7,0,0,0,0);
    cycle("concurrent responses",0,0,16'h80,1,'1,0,0,1,8,1,1,2,3);
    cycle("read stalled",1,0,16'h80,127,'1,0,1,1,9,0,0,0,0);
    cycle("read stall held",1,0,16'h80,127,'1,0,1,1,9,1,1,3,2);
    cycle("read stall release",1,0,16'h80,127,'1,0,0,1,9,0,0,0,0);
    cycle("initial bad read",1,0,16'h81,1,'1,0,0,1,10,0,0,0,0);
    cycle("initial bad write",0,1,16'h81,3,'1,'1,0,1,11,0,0,0,0);
    cycle("burst first accepted",0,1,16'h100,3,'1,512'h11,0,1,12,0,0,0,0);
    cycle("burst later bad despite aligned first",0,1,16'h101,3,'1,512'h22,0,1,12,0,0,0,0);
    cycle("burst later bad and stalled",0,1,16'h13f,3,'1,512'h22,1,1,12,0,0,0,0);
    cycle("burst later aligned stalled",0,1,16'h100,3,'1,512'h22,1,1,12,0,0,0,0);
    cycle("burst stalled changes to bad",0,1,16'h102,3,'1,512'h22,1,1,12,0,0,0,0);
    cycle("burst second accepted",0,1,16'h100,3,'1,512'h22,0,1,12,0,0,0,0);
    cycle("burst final accepted",0,1,16'h100,3,'1,512'h33,0,1,12,0,0,0,0);
    cycle("burst write response",0,0,16'h100,1,'1,0,0,1,12,0,1,0,2);
    cycle("reset mid stalled write",0,1,16'h140,1,'1,'1,1,0,13,1,1,1,2);
    cycle("reset release write",0,1,16'h140,1,'1,'1,0,1,13,0,0,0,0);
    cycle("highest aligned address",1,0,16'hffc0,1,'1,0,0,1,255,0,0,0,0);
    // Every byte offset, each request channel, with and without sink stalls.
    for (int off=1;off<64;off++) begin
      cycle("bad read offset sweep",1,0,16'(256+off),1,'1,0,off[0],1,8'(off),0,0,0,0);
      cycle("bad write offset sweep",0,1,16'(256+off),1,'1,'1,!off[0],1,8'(off),0,0,0,0);
    end
    cycle("read burst command",1,0,16'h80,3,'1,0,0,1,21,0,0,0,0);
    for (int beat=0;beat<3;beat++)
      cycle("read burst response",0,0,16'h80,3,'1,0,0,1,21,1,0,2'(beat),0);
    ck(scenarios == 154, "scenario count");
    $display("PASS scenarios=%0d checks=%0d",scenarios,checks);
    $finish;
  end
  initial begin #100000; $fatal(1,"TIMEOUT"); end
endmodule

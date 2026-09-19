`timescale 1ns/1ps
module tb_mem_ss_smoke;
  bit [1:0] done = 0;
  bit traffic_enabled = 0;
  logic  mem0_pll_ref_clk;
  logic  mem0_oct_rzqin;
  wire [0:0] mem0_ddr4_ck;
  wire [0:0] mem0_ddr4_ck_n;
  wire [16:0] mem0_ddr4_a;
  wire [0:0] mem0_ddr4_act_n;
  wire [1:0] mem0_ddr4_ba;
  wire [1:0] mem0_ddr4_bg;
  wire [0:0] mem0_ddr4_cke;
  wire [0:0] mem0_ddr4_cs_n;
  wire [0:0] mem0_ddr4_odt;
  wire [0:0] mem0_ddr4_reset_n;
  wire [0:0] mem0_ddr4_par;
  wire [0:0] mem0_ddr4_alert_n;
  wire [7:0] mem0_ddr4_dqs;
  wire [7:0] mem0_ddr4_dqs_n;
  wire [63:0] mem0_ddr4_dq;
  wire [7:0] mem0_ddr4_dbi_n;
  wire  mem0_ss_app_usr_clk;
  wire  mem0_ss_app_usr_reset_n;
  logic  mem1_pll_ref_clk;
  logic  mem1_oct_rzqin;
  wire [0:0] mem1_ddr4_ck;
  wire [0:0] mem1_ddr4_ck_n;
  wire [16:0] mem1_ddr4_a;
  wire [0:0] mem1_ddr4_act_n;
  wire [1:0] mem1_ddr4_ba;
  wire [1:0] mem1_ddr4_bg;
  wire [0:0] mem1_ddr4_cke;
  wire [0:0] mem1_ddr4_cs_n;
  wire [0:0] mem1_ddr4_odt;
  wire [0:0] mem1_ddr4_reset_n;
  wire [0:0] mem1_ddr4_par;
  wire [0:0] mem1_ddr4_alert_n;
  wire [7:0] mem1_ddr4_dqs;
  wire [7:0] mem1_ddr4_dqs_n;
  wire [63:0] mem1_ddr4_dq;
  wire [7:0] mem1_ddr4_dbi_n;
  wire  mem1_ss_app_usr_clk;
  wire  mem1_ss_app_usr_reset_n;
  logic  app_ss_rst_req;
  wire  ss_app_rst_rdy;
  logic  app_ss_cold_rst_n;
  wire  ss_app_cold_rst_ack_n;
  wire  i0_ss_app_mm_awready;
  logic  i0_app_ss_mm_awvalid;
  logic [8:0] i0_app_ss_mm_awid;
  logic [33:0] i0_app_ss_mm_awaddr;
  logic [7:0] i0_app_ss_mm_awlen;
  logic [2:0] i0_app_ss_mm_awsize;
  logic [1:0] i0_app_ss_mm_awburst;
  logic  i0_app_ss_mm_awlock;
  logic [3:0] i0_app_ss_mm_awcache;
  logic [2:0] i0_app_ss_mm_awprot;
  logic [3:0] i0_app_ss_mm_awqos;
  logic [13:0] i0_app_ss_mm_awuser;
  wire  i0_ss_app_mm_arready;
  logic  i0_app_ss_mm_arvalid;
  logic [8:0] i0_app_ss_mm_arid;
  logic [33:0] i0_app_ss_mm_araddr;
  logic [7:0] i0_app_ss_mm_arlen;
  logic [2:0] i0_app_ss_mm_arsize;
  logic [1:0] i0_app_ss_mm_arburst;
  logic  i0_app_ss_mm_arlock;
  logic [3:0] i0_app_ss_mm_arcache;
  logic [2:0] i0_app_ss_mm_arprot;
  logic [3:0] i0_app_ss_mm_arqos;
  logic [13:0] i0_app_ss_mm_aruser;
  wire  i0_ss_app_mm_wready;
  logic  i0_app_ss_mm_wvalid;
  logic [511:0] i0_app_ss_mm_wdata;
  logic [63:0] i0_app_ss_mm_wstrb;
  logic  i0_app_ss_mm_wlast;
  logic  i0_app_ss_mm_bready;
  wire  i0_ss_app_mm_bvalid;
  wire [8:0] i0_ss_app_mm_bid;
  wire [1:0] i0_ss_app_mm_bresp;
  wire  i0_ss_app_mm_buser;
  logic  i0_app_ss_mm_rready;
  wire  i0_ss_app_mm_rvalid;
  wire [8:0] i0_ss_app_mm_rid;
  wire [1:0] i0_ss_app_mm_rresp;
  wire [511:0] i0_ss_app_mm_rdata;
  wire  i0_ss_app_mm_rlast;
  wire  mem0_local_cal_success;
  wire  mem0_local_cal_fail;
  wire  i1_ss_app_mm_awready;
  logic  i1_app_ss_mm_awvalid;
  logic [8:0] i1_app_ss_mm_awid;
  logic [33:0] i1_app_ss_mm_awaddr;
  logic [7:0] i1_app_ss_mm_awlen;
  logic [2:0] i1_app_ss_mm_awsize;
  logic [1:0] i1_app_ss_mm_awburst;
  logic  i1_app_ss_mm_awlock;
  logic [3:0] i1_app_ss_mm_awcache;
  logic [2:0] i1_app_ss_mm_awprot;
  logic [3:0] i1_app_ss_mm_awqos;
  logic [13:0] i1_app_ss_mm_awuser;
  wire  i1_ss_app_mm_arready;
  logic  i1_app_ss_mm_arvalid;
  logic [8:0] i1_app_ss_mm_arid;
  logic [33:0] i1_app_ss_mm_araddr;
  logic [7:0] i1_app_ss_mm_arlen;
  logic [2:0] i1_app_ss_mm_arsize;
  logic [1:0] i1_app_ss_mm_arburst;
  logic  i1_app_ss_mm_arlock;
  logic [3:0] i1_app_ss_mm_arcache;
  logic [2:0] i1_app_ss_mm_arprot;
  logic [3:0] i1_app_ss_mm_arqos;
  logic [13:0] i1_app_ss_mm_aruser;
  wire  i1_ss_app_mm_wready;
  logic  i1_app_ss_mm_wvalid;
  logic [511:0] i1_app_ss_mm_wdata;
  logic [63:0] i1_app_ss_mm_wstrb;
  logic  i1_app_ss_mm_wlast;
  logic  i1_app_ss_mm_bready;
  wire  i1_ss_app_mm_bvalid;
  wire [8:0] i1_ss_app_mm_bid;
  wire [1:0] i1_ss_app_mm_bresp;
  wire  i1_ss_app_mm_buser;
  logic  i1_app_ss_mm_rready;
  wire  i1_ss_app_mm_rvalid;
  wire [8:0] i1_ss_app_mm_rid;
  wire [1:0] i1_ss_app_mm_rresp;
  wire [511:0] i1_ss_app_mm_rdata;
  wire  i1_ss_app_mm_rlast;
  wire  mem1_local_cal_success;
  wire  mem1_local_cal_fail;
  mem_ss dut (
    .mem0_pll_ref_clk(mem0_pll_ref_clk),
    .mem0_oct_rzqin(mem0_oct_rzqin),
    .mem0_ddr4_ck(mem0_ddr4_ck),
    .mem0_ddr4_ck_n(mem0_ddr4_ck_n),
    .mem0_ddr4_a(mem0_ddr4_a),
    .mem0_ddr4_act_n(mem0_ddr4_act_n),
    .mem0_ddr4_ba(mem0_ddr4_ba),
    .mem0_ddr4_bg(mem0_ddr4_bg),
    .mem0_ddr4_cke(mem0_ddr4_cke),
    .mem0_ddr4_cs_n(mem0_ddr4_cs_n),
    .mem0_ddr4_odt(mem0_ddr4_odt),
    .mem0_ddr4_reset_n(mem0_ddr4_reset_n),
    .mem0_ddr4_par(mem0_ddr4_par),
    .mem0_ddr4_alert_n(mem0_ddr4_alert_n),
    .mem0_ddr4_dqs(mem0_ddr4_dqs),
    .mem0_ddr4_dqs_n(mem0_ddr4_dqs_n),
    .mem0_ddr4_dq(mem0_ddr4_dq),
    .mem0_ddr4_dbi_n(mem0_ddr4_dbi_n),
    .mem0_ss_app_usr_clk(mem0_ss_app_usr_clk),
    .mem0_ss_app_usr_reset_n(mem0_ss_app_usr_reset_n),
    .mem1_pll_ref_clk(mem1_pll_ref_clk),
    .mem1_oct_rzqin(mem1_oct_rzqin),
    .mem1_ddr4_ck(mem1_ddr4_ck),
    .mem1_ddr4_ck_n(mem1_ddr4_ck_n),
    .mem1_ddr4_a(mem1_ddr4_a),
    .mem1_ddr4_act_n(mem1_ddr4_act_n),
    .mem1_ddr4_ba(mem1_ddr4_ba),
    .mem1_ddr4_bg(mem1_ddr4_bg),
    .mem1_ddr4_cke(mem1_ddr4_cke),
    .mem1_ddr4_cs_n(mem1_ddr4_cs_n),
    .mem1_ddr4_odt(mem1_ddr4_odt),
    .mem1_ddr4_reset_n(mem1_ddr4_reset_n),
    .mem1_ddr4_par(mem1_ddr4_par),
    .mem1_ddr4_alert_n(mem1_ddr4_alert_n),
    .mem1_ddr4_dqs(mem1_ddr4_dqs),
    .mem1_ddr4_dqs_n(mem1_ddr4_dqs_n),
    .mem1_ddr4_dq(mem1_ddr4_dq),
    .mem1_ddr4_dbi_n(mem1_ddr4_dbi_n),
    .mem1_ss_app_usr_clk(mem1_ss_app_usr_clk),
    .mem1_ss_app_usr_reset_n(mem1_ss_app_usr_reset_n),
    .app_ss_rst_req(app_ss_rst_req),
    .ss_app_rst_rdy(ss_app_rst_rdy),
    .app_ss_cold_rst_n(app_ss_cold_rst_n),
    .ss_app_cold_rst_ack_n(ss_app_cold_rst_ack_n),
    .i0_ss_app_mm_awready(i0_ss_app_mm_awready),
    .i0_app_ss_mm_awvalid(i0_app_ss_mm_awvalid),
    .i0_app_ss_mm_awid(i0_app_ss_mm_awid),
    .i0_app_ss_mm_awaddr(i0_app_ss_mm_awaddr),
    .i0_app_ss_mm_awlen(i0_app_ss_mm_awlen),
    .i0_app_ss_mm_awsize(i0_app_ss_mm_awsize),
    .i0_app_ss_mm_awburst(i0_app_ss_mm_awburst),
    .i0_app_ss_mm_awlock(i0_app_ss_mm_awlock),
    .i0_app_ss_mm_awcache(i0_app_ss_mm_awcache),
    .i0_app_ss_mm_awprot(i0_app_ss_mm_awprot),
    .i0_app_ss_mm_awqos(i0_app_ss_mm_awqos),
    .i0_app_ss_mm_awuser(i0_app_ss_mm_awuser),
    .i0_ss_app_mm_arready(i0_ss_app_mm_arready),
    .i0_app_ss_mm_arvalid(i0_app_ss_mm_arvalid),
    .i0_app_ss_mm_arid(i0_app_ss_mm_arid),
    .i0_app_ss_mm_araddr(i0_app_ss_mm_araddr),
    .i0_app_ss_mm_arlen(i0_app_ss_mm_arlen),
    .i0_app_ss_mm_arsize(i0_app_ss_mm_arsize),
    .i0_app_ss_mm_arburst(i0_app_ss_mm_arburst),
    .i0_app_ss_mm_arlock(i0_app_ss_mm_arlock),
    .i0_app_ss_mm_arcache(i0_app_ss_mm_arcache),
    .i0_app_ss_mm_arprot(i0_app_ss_mm_arprot),
    .i0_app_ss_mm_arqos(i0_app_ss_mm_arqos),
    .i0_app_ss_mm_aruser(i0_app_ss_mm_aruser),
    .i0_ss_app_mm_wready(i0_ss_app_mm_wready),
    .i0_app_ss_mm_wvalid(i0_app_ss_mm_wvalid),
    .i0_app_ss_mm_wdata(i0_app_ss_mm_wdata),
    .i0_app_ss_mm_wstrb(i0_app_ss_mm_wstrb),
    .i0_app_ss_mm_wlast(i0_app_ss_mm_wlast),
    .i0_app_ss_mm_bready(i0_app_ss_mm_bready),
    .i0_ss_app_mm_bvalid(i0_ss_app_mm_bvalid),
    .i0_ss_app_mm_bid(i0_ss_app_mm_bid),
    .i0_ss_app_mm_bresp(i0_ss_app_mm_bresp),
    .i0_ss_app_mm_buser(i0_ss_app_mm_buser),
    .i0_app_ss_mm_rready(i0_app_ss_mm_rready),
    .i0_ss_app_mm_rvalid(i0_ss_app_mm_rvalid),
    .i0_ss_app_mm_rid(i0_ss_app_mm_rid),
    .i0_ss_app_mm_rresp(i0_ss_app_mm_rresp),
    .i0_ss_app_mm_rdata(i0_ss_app_mm_rdata),
    .i0_ss_app_mm_rlast(i0_ss_app_mm_rlast),
    .mem0_local_cal_success(mem0_local_cal_success),
    .mem0_local_cal_fail(mem0_local_cal_fail),
    .i1_ss_app_mm_awready(i1_ss_app_mm_awready),
    .i1_app_ss_mm_awvalid(i1_app_ss_mm_awvalid),
    .i1_app_ss_mm_awid(i1_app_ss_mm_awid),
    .i1_app_ss_mm_awaddr(i1_app_ss_mm_awaddr),
    .i1_app_ss_mm_awlen(i1_app_ss_mm_awlen),
    .i1_app_ss_mm_awsize(i1_app_ss_mm_awsize),
    .i1_app_ss_mm_awburst(i1_app_ss_mm_awburst),
    .i1_app_ss_mm_awlock(i1_app_ss_mm_awlock),
    .i1_app_ss_mm_awcache(i1_app_ss_mm_awcache),
    .i1_app_ss_mm_awprot(i1_app_ss_mm_awprot),
    .i1_app_ss_mm_awqos(i1_app_ss_mm_awqos),
    .i1_app_ss_mm_awuser(i1_app_ss_mm_awuser),
    .i1_ss_app_mm_arready(i1_ss_app_mm_arready),
    .i1_app_ss_mm_arvalid(i1_app_ss_mm_arvalid),
    .i1_app_ss_mm_arid(i1_app_ss_mm_arid),
    .i1_app_ss_mm_araddr(i1_app_ss_mm_araddr),
    .i1_app_ss_mm_arlen(i1_app_ss_mm_arlen),
    .i1_app_ss_mm_arsize(i1_app_ss_mm_arsize),
    .i1_app_ss_mm_arburst(i1_app_ss_mm_arburst),
    .i1_app_ss_mm_arlock(i1_app_ss_mm_arlock),
    .i1_app_ss_mm_arcache(i1_app_ss_mm_arcache),
    .i1_app_ss_mm_arprot(i1_app_ss_mm_arprot),
    .i1_app_ss_mm_arqos(i1_app_ss_mm_arqos),
    .i1_app_ss_mm_aruser(i1_app_ss_mm_aruser),
    .i1_ss_app_mm_wready(i1_ss_app_mm_wready),
    .i1_app_ss_mm_wvalid(i1_app_ss_mm_wvalid),
    .i1_app_ss_mm_wdata(i1_app_ss_mm_wdata),
    .i1_app_ss_mm_wstrb(i1_app_ss_mm_wstrb),
    .i1_app_ss_mm_wlast(i1_app_ss_mm_wlast),
    .i1_app_ss_mm_bready(i1_app_ss_mm_bready),
    .i1_ss_app_mm_bvalid(i1_ss_app_mm_bvalid),
    .i1_ss_app_mm_bid(i1_ss_app_mm_bid),
    .i1_ss_app_mm_bresp(i1_ss_app_mm_bresp),
    .i1_ss_app_mm_buser(i1_ss_app_mm_buser),
    .i1_app_ss_mm_rready(i1_app_ss_mm_rready),
    .i1_ss_app_mm_rvalid(i1_ss_app_mm_rvalid),
    .i1_ss_app_mm_rid(i1_ss_app_mm_rid),
    .i1_ss_app_mm_rresp(i1_ss_app_mm_rresp),
    .i1_ss_app_mm_rdata(i1_ss_app_mm_rdata),
    .i1_ss_app_mm_rlast(i1_ss_app_mm_rlast),
    .mem1_local_cal_success(mem1_local_cal_success),
    .mem1_local_cal_fail(mem1_local_cal_fail)
  );
  ed_sim_mem memory0 (
    .mem_ck(mem0_ddr4_ck),
    .mem_ck_n(mem0_ddr4_ck_n),
    .mem_a(mem0_ddr4_a),
    .mem_act_n(mem0_ddr4_act_n),
    .mem_ba(mem0_ddr4_ba),
    .mem_bg(mem0_ddr4_bg),
    .mem_cke(mem0_ddr4_cke),
    .mem_cs_n(mem0_ddr4_cs_n),
    .mem_odt(mem0_ddr4_odt),
    .mem_reset_n(mem0_ddr4_reset_n),
    .mem_par(mem0_ddr4_par),
    .mem_alert_n(mem0_ddr4_alert_n),
    .mem_dqs(mem0_ddr4_dqs),
    .mem_dqs_n(mem0_ddr4_dqs_n),
    .mem_dq(mem0_ddr4_dq),
    .mem_dbi_n(mem0_ddr4_dbi_n)
  );
  initial mem0_pll_ref_clk = 0;
  always #15.00015 mem0_pll_ref_clk = ~mem0_pll_ref_clk;
  initial mem0_oct_rzqin = 1'b0;
  ed_sim_mem_group1 memory1 (
    .mem_ck(mem1_ddr4_ck),
    .mem_ck_n(mem1_ddr4_ck_n),
    .mem_a(mem1_ddr4_a),
    .mem_act_n(mem1_ddr4_act_n),
    .mem_ba(mem1_ddr4_ba),
    .mem_bg(mem1_ddr4_bg),
    .mem_cke(mem1_ddr4_cke),
    .mem_cs_n(mem1_ddr4_cs_n),
    .mem_odt(mem1_ddr4_odt),
    .mem_reset_n(mem1_ddr4_reset_n),
    .mem_par(mem1_ddr4_par),
    .mem_alert_n(mem1_ddr4_alert_n),
    .mem_dqs(mem1_ddr4_dqs),
    .mem_dqs_n(mem1_ddr4_dqs_n),
    .mem_dq(mem1_ddr4_dq),
    .mem_dbi_n(mem1_ddr4_dbi_n)
  );
  initial mem1_pll_ref_clk = 0;
  always #15.00015 mem1_pll_ref_clk = ~mem1_pll_ref_clk;
  initial mem1_oct_rzqin = 1'b0;
  // Actual reset controller is clocked from EMIF0 ref_clk_out and reset by
  // EMIF0 pll_locked (evidence/mem_ss_inner.v). Implementation is encrypted.
  // Initial cold assertion is a REVIEW ITEM; no warm/repeated reset is issued.
  initial begin
    app_ss_rst_req = 0;
    app_ss_cold_rst_n = 0;
    repeat (100) @(negedge mem0_pll_ref_clk);
    app_ss_cold_rst_n = 1;
    wait (mem0_ss_app_usr_reset_n === 1'b1 &&
          mem1_ss_app_usr_reset_n === 1'b1 &&
          mem0_local_cal_success === 1'b1 &&
          mem1_local_cal_success === 1'b1 &&
          ss_app_cold_rst_ack_n === 1'b1);
    traffic_enabled = 1;
  end
  initial begin
    #500000;
    if (!traffic_enabled) $fatal(1, "DDR_SMOKE_FAIL startup_timeout_500us");
  end
  initial begin
    #1000000;
    $fatal(1, "DDR_SMOKE_FAIL watchdog_1ms");
  end
  always @(mem0_local_cal_fail or mem1_local_cal_fail)
    if (mem0_local_cal_fail === 1'b1 || mem1_local_cal_fail === 1'b1)
      $fatal(1, "DDR_SMOKE_FAIL calibration_failure");
  initial begin
    wait (done === 2'b11);
    $display("DDR_SMOKE_PASS channels=2 writes=4 reads=4 bits_checked=2048");
    $finish;
  end
  function automatic logic [511:0] pattern(input int channel, input int word_index);
    for (int lane=0; lane<16; lane++)
      pattern[lane*32 +: 32] = 32'hA5963C69 ^ (32'h10204081 * (lane+1)) ^
                               (channel ? 32'hD3B75E19 : 32'h29C4A6F0) ^
                               (word_index ? 32'hF0E1D2C3 : 32'h13579BDF);
  endfunction


  task automatic write_0(input int index);
    bit aw_done, w_done, b_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(0*16 + index + 1);
    aw_done=0; w_done=0; b_done=0; cycles=0;
    @(negedge mem0_ss_app_usr_clk);
    i0_app_ss_mm_awaddr=34'(index*64); i0_app_ss_mm_awid=expected_id; i0_app_ss_mm_awvalid=1;
    i0_app_ss_mm_wdata=pattern(0,index); i0_app_ss_mm_wvalid=1;
    // AW and W remain independent. No requirement on their acceptance order.
    while (!b_done && cycles < 4096) begin
      @(posedge mem0_ss_app_usr_clk);
      cycles++;
      if (i0_app_ss_mm_awvalid && i0_ss_app_mm_awready === 1'b1) aw_done=1;
      if (i0_app_ss_mm_wvalid && i0_ss_app_mm_wready === 1'b1) w_done=1;
      if (i0_app_ss_mm_bready && i0_ss_app_mm_bvalid === 1'b1) begin
        if ($isunknown({i0_ss_app_mm_bid,i0_ss_app_mm_bresp,i0_ss_app_mm_buser}) || i0_ss_app_mm_bid !== expected_id || i0_ss_app_mm_bresp !== 2'b00)
          $fatal(1,"DDR_SMOKE_FAIL channel=0 write index=%0d id/resp/XZ",index);
        b_done=1;
      end
      @(negedge mem0_ss_app_usr_clk);
      if (aw_done) i0_app_ss_mm_awvalid=0;
      if (w_done) i0_app_ss_mm_wvalid=0;
      i0_app_ss_mm_bready=aw_done && w_done && !b_done;
    end
    i0_app_ss_mm_bready=0;
    if (!b_done) $fatal(1,"DDR_SMOKE_FAIL channel=0 write_timeout index=%0d",index);
  endtask
  task automatic read_0(input int index);
    bit ar_done, r_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(0*16 + index + 5);
    ar_done=0; r_done=0; cycles=0;
    @(negedge mem0_ss_app_usr_clk);
    i0_app_ss_mm_araddr=34'(index*64); i0_app_ss_mm_arid=expected_id; i0_app_ss_mm_arvalid=1;
    while (!r_done && cycles < 4096) begin
      @(posedge mem0_ss_app_usr_clk);
      cycles++;
      if (i0_app_ss_mm_arvalid && i0_ss_app_mm_arready === 1'b1) ar_done=1;
      if (i0_app_ss_mm_rready && i0_ss_app_mm_rvalid === 1'b1) begin
        if ($isunknown({i0_ss_app_mm_rid,i0_ss_app_mm_rresp,i0_ss_app_mm_rlast,i0_ss_app_mm_rdata}) ||
            i0_ss_app_mm_rid !== expected_id || i0_ss_app_mm_rresp !== 2'b00 || i0_ss_app_mm_rlast !== 1'b1 ||
            i0_ss_app_mm_rdata !== pattern(0,index))
          $fatal(1,"DDR_SMOKE_FAIL channel=0 read index=%0d id/resp/last/data/XZ",index);
        r_done=1;
      end
      @(negedge mem0_ss_app_usr_clk);
      if (ar_done) i0_app_ss_mm_arvalid=0;
      i0_app_ss_mm_rready=ar_done && !r_done;
    end
    i0_app_ss_mm_rready=0;
    if (!r_done) $fatal(1,"DDR_SMOKE_FAIL channel=0 read_timeout index=%0d",index);
  endtask
  initial begin
    i0_app_ss_mm_awvalid='0;
    i0_app_ss_mm_awid='0;
    i0_app_ss_mm_awaddr='0;
    i0_app_ss_mm_awlen='0;
    i0_app_ss_mm_awsize=3'd6;
    i0_app_ss_mm_awburst=2'b01;
    i0_app_ss_mm_awlock='0;
    i0_app_ss_mm_awcache='0;
    i0_app_ss_mm_awprot='0;
    i0_app_ss_mm_awqos='0;
    i0_app_ss_mm_awuser='0;
    i0_app_ss_mm_arvalid='0;
    i0_app_ss_mm_arid='0;
    i0_app_ss_mm_araddr='0;
    i0_app_ss_mm_arlen='0;
    i0_app_ss_mm_arsize=3'd6;
    i0_app_ss_mm_arburst=2'b01;
    i0_app_ss_mm_arlock='0;
    i0_app_ss_mm_arcache='0;
    i0_app_ss_mm_arprot='0;
    i0_app_ss_mm_arqos='0;
    i0_app_ss_mm_aruser='0;
    i0_app_ss_mm_wvalid='0;
    i0_app_ss_mm_wdata='0;
    i0_app_ss_mm_wstrb='1;
    i0_app_ss_mm_wlast='1;
    i0_app_ss_mm_bready='0;
    i0_app_ss_mm_rready='0;
    wait (traffic_enabled);
    write_0(0); write_0(1);
    read_0(0); read_0(1);
    $display("DDR_SMOKE_CHANNEL_DONE channel=0 writes=2 reads=2");
    done[0]=1;
  end
  always @(posedge mem0_ss_app_usr_clk) if (traffic_enabled) begin
    if (mem0_ss_app_usr_reset_n !== 1'b1 || mem0_local_cal_success !== 1'b1 ||
        mem0_local_cal_fail !== 1'b0)
      $fatal(1,"DDR_SMOKE_FAIL channel=0 status_lost_or_XZ");
  end


  task automatic write_1(input int index);
    bit aw_done, w_done, b_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(1*16 + index + 1);
    aw_done=0; w_done=0; b_done=0; cycles=0;
    @(negedge mem1_ss_app_usr_clk);
    i1_app_ss_mm_awaddr=34'(index*64); i1_app_ss_mm_awid=expected_id; i1_app_ss_mm_awvalid=1;
    i1_app_ss_mm_wdata=pattern(1,index); i1_app_ss_mm_wvalid=1;
    // AW and W remain independent. No requirement on their acceptance order.
    while (!b_done && cycles < 4096) begin
      @(posedge mem1_ss_app_usr_clk);
      cycles++;
      if (i1_app_ss_mm_awvalid && i1_ss_app_mm_awready === 1'b1) aw_done=1;
      if (i1_app_ss_mm_wvalid && i1_ss_app_mm_wready === 1'b1) w_done=1;
      if (i1_app_ss_mm_bready && i1_ss_app_mm_bvalid === 1'b1) begin
        if ($isunknown({i1_ss_app_mm_bid,i1_ss_app_mm_bresp,i1_ss_app_mm_buser}) || i1_ss_app_mm_bid !== expected_id || i1_ss_app_mm_bresp !== 2'b00)
          $fatal(1,"DDR_SMOKE_FAIL channel=1 write index=%0d id/resp/XZ",index);
        b_done=1;
      end
      @(negedge mem1_ss_app_usr_clk);
      if (aw_done) i1_app_ss_mm_awvalid=0;
      if (w_done) i1_app_ss_mm_wvalid=0;
      i1_app_ss_mm_bready=aw_done && w_done && !b_done;
    end
    i1_app_ss_mm_bready=0;
    if (!b_done) $fatal(1,"DDR_SMOKE_FAIL channel=1 write_timeout index=%0d",index);
  endtask
  task automatic read_1(input int index);
    bit ar_done, r_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(1*16 + index + 5);
    ar_done=0; r_done=0; cycles=0;
    @(negedge mem1_ss_app_usr_clk);
    i1_app_ss_mm_araddr=34'(index*64); i1_app_ss_mm_arid=expected_id; i1_app_ss_mm_arvalid=1;
    while (!r_done && cycles < 4096) begin
      @(posedge mem1_ss_app_usr_clk);
      cycles++;
      if (i1_app_ss_mm_arvalid && i1_ss_app_mm_arready === 1'b1) ar_done=1;
      if (i1_app_ss_mm_rready && i1_ss_app_mm_rvalid === 1'b1) begin
        if ($isunknown({i1_ss_app_mm_rid,i1_ss_app_mm_rresp,i1_ss_app_mm_rlast,i1_ss_app_mm_rdata}) ||
            i1_ss_app_mm_rid !== expected_id || i1_ss_app_mm_rresp !== 2'b00 || i1_ss_app_mm_rlast !== 1'b1 ||
            i1_ss_app_mm_rdata !== pattern(1,index))
          $fatal(1,"DDR_SMOKE_FAIL channel=1 read index=%0d id/resp/last/data/XZ",index);
        r_done=1;
      end
      @(negedge mem1_ss_app_usr_clk);
      if (ar_done) i1_app_ss_mm_arvalid=0;
      i1_app_ss_mm_rready=ar_done && !r_done;
    end
    i1_app_ss_mm_rready=0;
    if (!r_done) $fatal(1,"DDR_SMOKE_FAIL channel=1 read_timeout index=%0d",index);
  endtask
  initial begin
    i1_app_ss_mm_awvalid='0;
    i1_app_ss_mm_awid='0;
    i1_app_ss_mm_awaddr='0;
    i1_app_ss_mm_awlen='0;
    i1_app_ss_mm_awsize=3'd6;
    i1_app_ss_mm_awburst=2'b01;
    i1_app_ss_mm_awlock='0;
    i1_app_ss_mm_awcache='0;
    i1_app_ss_mm_awprot='0;
    i1_app_ss_mm_awqos='0;
    i1_app_ss_mm_awuser='0;
    i1_app_ss_mm_arvalid='0;
    i1_app_ss_mm_arid='0;
    i1_app_ss_mm_araddr='0;
    i1_app_ss_mm_arlen='0;
    i1_app_ss_mm_arsize=3'd6;
    i1_app_ss_mm_arburst=2'b01;
    i1_app_ss_mm_arlock='0;
    i1_app_ss_mm_arcache='0;
    i1_app_ss_mm_arprot='0;
    i1_app_ss_mm_arqos='0;
    i1_app_ss_mm_aruser='0;
    i1_app_ss_mm_wvalid='0;
    i1_app_ss_mm_wdata='0;
    i1_app_ss_mm_wstrb='1;
    i1_app_ss_mm_wlast='1;
    i1_app_ss_mm_bready='0;
    i1_app_ss_mm_rready='0;
    wait (traffic_enabled);
    write_1(0); write_1(1);
    read_1(0); read_1(1);
    $display("DDR_SMOKE_CHANNEL_DONE channel=1 writes=2 reads=2");
    done[1]=1;
  end
  always @(posedge mem1_ss_app_usr_clk) if (traffic_enabled) begin
    if (mem1_ss_app_usr_reset_n !== 1'b1 || mem1_local_cal_success !== 1'b1 ||
        mem1_local_cal_fail !== 1'b0)
      $fatal(1,"DDR_SMOKE_FAIL channel=1 status_lost_or_XZ");
  end

endmodule

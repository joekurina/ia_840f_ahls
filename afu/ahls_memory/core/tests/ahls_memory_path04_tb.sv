// Full generated kernel + DMA/fabric + actual PIM bank adapters.
// Synthetic byte memories; no physical DDR/PCIe/OPAE or runtime recovery claims.
`timescale 1ns/1ps
`include "ofs_plat_if.vh"
module ahls_memory_path_tb;
    logic clk=0, bclk0=0, bclk1=0, reset_n=0;
    always #5 clk=~clk;
    always #7 bclk0=~bclk0;
    always #11 bclk1=~bclk1;
    int checks=0, completed_cases=0, checked_elements=0, checked_bytes=0;
    int dma_completed=0, mmio_reads=0, mmio_writes=0;
    wire irq;
    wire [63:0] exception_unused;
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(20),.DATA_WIDTH(64),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(16),.WID_WIDTH(16),.USER_WIDTH(1)) mmio();
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(57),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(4)) host();
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(34),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(18),.WID_WIDTH(18),.USER_WIDTH(2)) bank[2]();
    ofs_plat_axi_mem_if #(.ADDR_WIDTH(34),.DATA_WIDTH(512),.BURST_CNT_WIDTH(8),
        .RID_WIDTH(9),.WID_WIDTH(9),.USER_WIDTH(1)) physical[2]();
    assign mmio.clk=clk; assign mmio.reset_n=reset_n; assign mmio.instance_number=0;
    assign host.clk=clk; assign host.reset_n=reset_n; assign host.instance_number=1;
    assign physical[0].clk=bclk0; assign physical[1].clk=bclk1;
    for (genvar b=0;b<2;b++) begin : bank_maps
        assign physical[b].reset_n=reset_n;
        assign physical[b].instance_number=b+2;
        assign bank[b].aw.atop='0;
        ia840f_ahls_memory_bank_shim #(.ADD_CLOCK_CROSSING(1),.ADD_TIMING_REG_STAGES(3)) shim(
            .to_fiu(physical[b]),.to_afu(bank[b]),.afu_clk(clk),.afu_reset_n(reset_n));
    end
    ahls_axi_memory_model #(.ENDPOINT(0),.LINEAR_HOST(1)) host_model(host);
    ahls_axi_memory_model #(.ENDPOINT(1)) bank0_model(physical[0]);
    ahls_axi_memory_model #(.ENDPOINT(2)) bank1_model(physical[1]);
    ia840f_ahls_memory_core dut (
        .clock_reset_clk(clk),
        .clock_reset_reset_reset_n(reset_n),
        .freeze_freeze(1'b0),
        .device_exception_bus_data(exception_unused),
        .kernel_irqs_irq(irq),
        .mmio_control_awid(mmio.aw.id),
        .mmio_control_awaddr(mmio.aw.addr),
        .mmio_control_awlen(mmio.aw.len),
        .mmio_control_awsize(mmio.aw.size),
        .mmio_control_awburst(mmio.aw.burst),
        .mmio_control_awuser(mmio.aw.user),
        .mmio_control_awvalid(mmio.awvalid),
        .mmio_control_awready(mmio.awready),
        .mmio_control_wdata(mmio.w.data),
        .mmio_control_wstrb(mmio.w.strb),
        .mmio_control_wvalid(mmio.wvalid),
        .mmio_control_wuser(mmio.w.user),
        .mmio_control_wready(mmio.wready),
        .mmio_control_bid(mmio.b.id),
        .mmio_control_bresp(mmio.b.resp),
        .mmio_control_buser(mmio.b.user),
        .mmio_control_bvalid(mmio.bvalid),
        .mmio_control_bready(mmio.bready),
        .mmio_control_arid(mmio.ar.id),
        .mmio_control_araddr(mmio.ar.addr),
        .mmio_control_arlen(mmio.ar.len),
        .mmio_control_arsize(mmio.ar.size),
        .mmio_control_arburst(mmio.ar.burst),
        .mmio_control_aruser(mmio.ar.user),
        .mmio_control_arvalid(mmio.arvalid),
        .mmio_control_arready(mmio.arready),
        .mmio_control_rid(mmio.r.id),
        .mmio_control_rdata(mmio.r.data),
        .mmio_control_rresp(mmio.r.resp),
        .mmio_control_rlast(mmio.r.last),
        .mmio_control_rvalid(mmio.rvalid),
        .mmio_control_rready(mmio.rready),
        .mmio_control_ruser(mmio.r.user),
        .bank_out0_awid(bank[0].aw.id),
        .bank_out0_awaddr(bank[0].aw.addr),
        .bank_out0_awlen(bank[0].aw.len),
        .bank_out0_awsize(bank[0].aw.size),
        .bank_out0_awburst(bank[0].aw.burst),
        .bank_out0_awlock(bank[0].aw.lock),
        .bank_out0_awcache(bank[0].aw.cache),
        .bank_out0_awprot(bank[0].aw.prot),
        .bank_out0_awuser(bank[0].aw.user),
        .bank_out0_awqos(bank[0].aw.qos),
        .bank_out0_awregion(bank[0].aw.region),
        .bank_out0_awvalid(bank[0].awvalid),
        .bank_out0_awready(bank[0].awready),
        .bank_out0_wdata(bank[0].w.data),
        .bank_out0_wstrb(bank[0].w.strb),
        .bank_out0_wlast(bank[0].w.last),
        .bank_out0_wvalid(bank[0].wvalid),
        .bank_out0_wuser(bank[0].w.user),
        .bank_out0_wready(bank[0].wready),
        .bank_out0_bid(bank[0].b.id),
        .bank_out0_bresp(bank[0].b.resp),
        .bank_out0_buser(bank[0].b.user),
        .bank_out0_bvalid(bank[0].bvalid),
        .bank_out0_bready(bank[0].bready),
        .bank_out0_arid(bank[0].ar.id),
        .bank_out0_araddr(bank[0].ar.addr),
        .bank_out0_arlen(bank[0].ar.len),
        .bank_out0_arsize(bank[0].ar.size),
        .bank_out0_arburst(bank[0].ar.burst),
        .bank_out0_arlock(bank[0].ar.lock),
        .bank_out0_arcache(bank[0].ar.cache),
        .bank_out0_arprot(bank[0].ar.prot),
        .bank_out0_aruser(bank[0].ar.user),
        .bank_out0_arqos(bank[0].ar.qos),
        .bank_out0_arregion(bank[0].ar.region),
        .bank_out0_arvalid(bank[0].arvalid),
        .bank_out0_arready(bank[0].arready),
        .bank_out0_rid(bank[0].r.id),
        .bank_out0_rdata(bank[0].r.data),
        .bank_out0_rresp(bank[0].r.resp),
        .bank_out0_rlast(bank[0].r.last),
        .bank_out0_rvalid(bank[0].rvalid),
        .bank_out0_rready(bank[0].rready),
        .bank_out0_ruser(bank[0].r.user),
        .bank_out1_awid(bank[1].aw.id),
        .bank_out1_awaddr(bank[1].aw.addr),
        .bank_out1_awlen(bank[1].aw.len),
        .bank_out1_awsize(bank[1].aw.size),
        .bank_out1_awburst(bank[1].aw.burst),
        .bank_out1_awlock(bank[1].aw.lock),
        .bank_out1_awcache(bank[1].aw.cache),
        .bank_out1_awprot(bank[1].aw.prot),
        .bank_out1_awuser(bank[1].aw.user),
        .bank_out1_awqos(bank[1].aw.qos),
        .bank_out1_awregion(bank[1].aw.region),
        .bank_out1_awvalid(bank[1].awvalid),
        .bank_out1_awready(bank[1].awready),
        .bank_out1_wdata(bank[1].w.data),
        .bank_out1_wstrb(bank[1].w.strb),
        .bank_out1_wlast(bank[1].w.last),
        .bank_out1_wvalid(bank[1].wvalid),
        .bank_out1_wuser(bank[1].w.user),
        .bank_out1_wready(bank[1].wready),
        .bank_out1_bid(bank[1].b.id),
        .bank_out1_bresp(bank[1].b.resp),
        .bank_out1_buser(bank[1].b.user),
        .bank_out1_bvalid(bank[1].bvalid),
        .bank_out1_bready(bank[1].bready),
        .bank_out1_arid(bank[1].ar.id),
        .bank_out1_araddr(bank[1].ar.addr),
        .bank_out1_arlen(bank[1].ar.len),
        .bank_out1_arsize(bank[1].ar.size),
        .bank_out1_arburst(bank[1].ar.burst),
        .bank_out1_arlock(bank[1].ar.lock),
        .bank_out1_arcache(bank[1].ar.cache),
        .bank_out1_arprot(bank[1].ar.prot),
        .bank_out1_aruser(bank[1].ar.user),
        .bank_out1_arqos(bank[1].ar.qos),
        .bank_out1_arregion(bank[1].ar.region),
        .bank_out1_arvalid(bank[1].arvalid),
        .bank_out1_arready(bank[1].arready),
        .bank_out1_rid(bank[1].r.id),
        .bank_out1_rdata(bank[1].r.data),
        .bank_out1_rresp(bank[1].r.resp),
        .bank_out1_rlast(bank[1].r.last),
        .bank_out1_rvalid(bank[1].rvalid),
        .bank_out1_rready(bank[1].rready),
        .bank_out1_ruser(bank[1].r.user),
        .host_awid(host.aw.id),
        .host_awaddr(host.aw.addr),
        .host_awlen(host.aw.len),
        .host_awsize(host.aw.size),
        .host_awburst(host.aw.burst),
        .host_awlock(host.aw.lock),
        .host_awcache(host.aw.cache),
        .host_awprot(host.aw.prot),
        .host_awuser(host.aw.user),
        .host_awqos(host.aw.qos),
        .host_awregion(host.aw.region),
        .host_awatop(host.aw.atop),
        .host_awvalid(host.awvalid),
        .host_awready(host.awready),
        .host_arid(host.ar.id),
        .host_araddr(host.ar.addr),
        .host_arlen(host.ar.len),
        .host_arsize(host.ar.size),
        .host_arburst(host.ar.burst),
        .host_arlock(host.ar.lock),
        .host_arcache(host.ar.cache),
        .host_arprot(host.ar.prot),
        .host_aruser(host.ar.user),
        .host_arqos(host.ar.qos),
        .host_arregion(host.ar.region),
        .host_arvalid(host.arvalid),
        .host_arready(host.arready),
        .host_wdata(host.w.data),
        .host_wstrb(host.w.strb),
        .host_wlast(host.w.last),
        .host_wuser(host.w.user),
        .host_wvalid(host.wvalid),
        .host_wready(host.wready),
        .host_rid(host.r.id),
        .host_rdata(host.r.data),
        .host_rresp(host.r.resp),
        .host_rlast(host.r.last),
        .host_ruser(host.r.user),
        .host_rvalid(host.rvalid),
        .host_rready(host.rready),
        .host_bid(host.b.id),
        .host_bresp(host.b.resp),
        .host_buser(host.b.user),
        .host_bvalid(host.bvalid),
        .host_bready(host.bready)
    );

    task automatic check(input bit ok, input string what);
        checks++;
        if (!ok) $fatal(1,"AHLS_PATH_FAIL %s time=%0t",what,$time);
    endtask
    task automatic wr64(input logic[19:0] addr, input logic[63:0] data);
        bit adone,wdone,bdone;
        adone=0;wdone=0;bdone=0;
        @(negedge clk);
        mmio.aw='0;mmio.aw.addr=addr;mmio.aw.size=3;mmio.aw.burst=1;
        mmio.aw.id=16'h31;mmio.aw.user=1;
        mmio.w='0;mmio.w.data=data;mmio.w.strb='1;mmio.w.last=1;
        mmio.awvalid=1;mmio.wvalid=0;mmio.bready=0;
        for (int t=0;t<20000;t++) begin
            @(posedge clk);
            if(mmio.awvalid&&mmio.awready) adone=1;
            if(mmio.wvalid&&mmio.wready) wdone=1;
            if(mmio.bvalid&&mmio.bready) begin
                check(mmio.b.resp===0,$sformatf("MMIO B addr=%h resp=%h",addr,mmio.b.resp));
                check(mmio.b.id===16'h31,"MMIO BID");bdone=1;
            end
            @(negedge clk);
            mmio.awvalid=!adone;mmio.wvalid=(t>=3)&&!wdone;
            mmio.bready=t>=8;
            if(bdone) break;
        end
        check(adone&&wdone&&bdone,$sformatf("MMIO write timeout %h",addr));
        mmio.awvalid=0;mmio.wvalid=0;mmio.bready=0;mmio_writes++;
    endtask
    task automatic rd64(input logic[19:0] addr, output logic[63:0] data);
        bit adone,rdone;
        adone=0;rdone=0;
        @(negedge clk);mmio.ar='0;mmio.ar.addr=addr;mmio.ar.size=3;
        mmio.ar.burst=1;mmio.ar.id=16'h52;mmio.ar.user=1;
        mmio.arvalid=1;mmio.rready=0;
        for(int t=0;t<20000;t++) begin
            @(posedge clk);
            if(mmio.arvalid&&mmio.arready) adone=1;
            if(mmio.rvalid&&mmio.rready) begin
                check(mmio.r.resp===0,$sformatf("MMIO R addr=%h resp=%h",addr,mmio.r.resp));
                check(mmio.r.id===16'h52,$sformatf("MMIO RID addr=%h rid=%h",addr,mmio.r.id)); // Upstream AXI-Lite has no RLAST.
                data=mmio.r.data;rdone=1;
            end
            @(negedge clk);mmio.arvalid=!adone;mmio.rready=t>=6;
            if(rdone) break;
        end
        check(adone&&rdone,$sformatf("MMIO read timeout %h",addr));
        mmio.arvalid=0;mmio.rready=0;mmio_reads++;
    endtask
    task automatic dma_copy(input longint unsigned src,dst,input int beats,mode);
        logic [63:0] before_status,st;
        int next_count;bit done;
        rd64(20'h48,before_status);next_count=(before_status[31:28]+1)&15;
        wr64(20'h28,src);wr64(20'h30,dst);wr64(20'h38,beats);
        wr64(20'h40,64'h80000000|(64'(mode)<<26));
        done=0;
        for(int t=0;t<1000;t++) begin
            rd64(20'h48,st);
            check(!st[13]&&!st[10]&&!st[7],$sformatf("DMA error status=%h",st));
            if(st[31:28]==next_count && !st[0] && st[1]) begin done=1;break;end
        end
        check(done,$sformatf("DMA timeout src=%h dst=%h status=%h",src,dst,st));
        dma_completed++;
    endtask
    function automatic int xvalue(input int c,i);return -37+i*11+c*3;endfunction
    function automatic int yvalue(input int c,i);return 91-i*7-c*5;endfunction
    task automatic run_case(input int c,n);
        int beats,copy_bytes,before_bytes,expected,lane,idx;
        byte unsigned want;
        logic [63:0] st,fin;
        bit done,drained;
        beats=(n+15)/16;copy_bytes=(beats+2)*64;
        $display("AHLS_PATH_CASE_BEGIN id=%0d n=%0d beats=%0d",c,n,beats);
        for(int j=0;j<beats*64;j++) begin
            host_model.storage['h1000+j]=8'hc3;
            host_model.storage['h2000+j]=8'h5a;
        end
        for(int j=0;j<copy_bytes;j++) begin
            host_model.storage['h3000+j]=8'(8'ha7^j^c);
            host_model.storage['h4000+j]=8'hdd;
        end
        for(int i=0;i<n;i++) begin
            host_model.write_int('h1000+i*4,xvalue(c,i));
            host_model.write_int('h2000+i*4,yvalue(c,i));
        end
        dma_copy(64'h1000,64'h1000,beats,1);
        dma_copy(64'h2000,64'h2000,beats,1);
        dma_copy(64'h3000,64'h400003fc0,beats+2,1);
        before_bytes=bank1_model.w_bytes;
        rd64(20'h10030,fin); // drain only while no invocation is outstanding
        repeat(10) @(posedge clk);
        rd64(20'h10030,fin);check(fin===0,"finish baseline");
        rd64(20'h10000,st);check(st[31:16]===16'd5&&!st[15]&&!st[1],"kernel idle/version baseline");
        wr64(20'h10080,64'h1000);wr64(20'h10088,64'h2000);
        wr64(20'h10090,64'h4000);wr64(20'h10098,n);
        wr64(20'h10008,64'd1);
        done=0;
        for(int t=0;t<2000;t++) begin
            rd64(20'h10000,st);
            if(st[1]&&!st[15]) begin done=1;break;end
        end
        check(done,$sformatf("kernel completion timeout status=%h",st));
        // Testbench observation, NOT a software fence or a physical drain ABI.
        drained=0;
        for(int t=0;t<20000;t++) begin
            @(negedge clk);
            check(bank1_model.w_bytes-before_bytes<=n*4,"excess kernel store bytes");
            if(bank1_model.w_bytes-before_bytes==n*4 && !bank1_model.wr_active &&
               !bank1_model.b_pending && !physical[1].bvalid) begin drained=1;break;end
        end
        check(drained,"synthetic kernel write-response drain");
        rd64(20'h10030,fin);check(fin===1,"fresh finish count");
        dma_copy(64'h400003fc0,64'h4000,beats+2,2);
        for(int i=0;i<n;i++) begin
            expected=xvalue(c,i)+yvalue(c,i);
            check(host_model.read_int('h4040+i*4)===expected,$sformatf("numeric c=%0d i=%0d expected=%0d actual=%0d",c,i,expected,host_model.read_int('h4040+i*4)));
            checked_elements++;
        end
        for(int j=0;j<copy_bytes;j++) begin
            if(j>=64 && j<64+n*4) begin
                idx=(j-64)/4;lane=(j-64)%4;expected=xvalue(c,idx)+yvalue(c,idx);
                want=expected[lane*8+:8];
            end else want=8'(8'ha7^j^c);
            check(host_model.storage['h4000+j]===want,$sformatf("copyback/guard c=%0d byte=%0d",c,j));checked_bytes++;
        end
        completed_cases++;
        $display("AHLS_PATH_CASE_PASS id=%0d n=%0d copied_bytes=%0d kernel_store_bytes=%0d",c,n,copy_bytes,bank1_model.w_bytes-before_bytes);
    endtask
    initial begin
        mmio.aw='0;mmio.w='0;mmio.ar='0;
        mmio.awvalid=0;mmio.wvalid=0;mmio.bready=0;mmio.arvalid=0;mmio.rready=0;
        repeat(200) @(negedge clk);reset_n=1;
        repeat(200) @(negedge clk);
        run_case(0,1);run_case(1,8);run_case(2,17);run_case(3,65);
        check(bank0_model.write_stalls>0&&bank1_model.write_stalls>0,"bank backpressure coverage");
        $display("AHLS_PATH_UNIT_PASS cases=%0d elements=%0d copied_bytes=%0d dma=%0d checks=%0d mmio_reads=%0d mmio_writes=%0d bank0_W=%0d bank1_W=%0d",completed_cases,checked_elements,checked_bytes,dma_completed,checks,mmio_reads,mmio_writes,bank0_model.w_count,bank1_model.w_count);
        $finish;
    end
    initial begin #10000000;$fatal(1,"AHLS_PATH_FAIL simulation watchdog");end
endmodule

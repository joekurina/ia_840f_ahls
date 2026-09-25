// Changed full-width generated HLS/DMA fabric + current AFU + actual page-safe PIM.
// Completion is polled through the actual AXI-Lite guard CSR, not test control wires.
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
    localparam logic [63:0] HOST_BASE=64'h0000012300000000;
    localparam logic [63:0] BANK0_BASE=64'h0000000200000000;
    localparam logic [63:0] BANK1_BASE=64'h0000000100000000;
    localparam logic [63:0] BANK_MASK=64'h00000003ffffffff;
    bit kernel_phase=0;
    longint unsigned kernel_x,kernel_y,kernel_z;
    int kernel_read_bytes=0,kernel_output_bytes=0;
    int hls_write_left=0,hls_write_index=0;
    longint unsigned hls_write_base;
    int hls_reads=0,hls_writes=0,early_finish_cases=0,pub_snapshots=0,pub_certificate_checks=0;
    int pre_aw_cross0=0,pre_aw_cross1=0,pre_ar_cross0=0,pre_ar_cross1=0;
    byte unsigned host_expected[0:65535];
    wire completion_start, producer_done, access_fault, completion_busy, completion_done;
    wire [7:0] completion_errors;
    wire [32:0] expected_bytes, accepted_bytes;
    wire bank1_dma_write_attempt;
    wire irq;
    wire [63:0] exception_unused;
    ofs_plat_axi_mem_lite_if #(.ADDR_WIDTH(20),.DATA_WIDTH(64),
        .RID_WIDTH(16),.WID_WIDTH(16),.USER_WIDTH(1)) mmio();
    ofs_plat_axi_mem_lite_if #(.ADDR_WIDTH(20),.DATA_WIDTH(64),
        .RID_WIDTH(16),.WID_WIDTH(16),.USER_WIDTH(1)) guarded_mmio();
    assign guarded_mmio.clk=clk;assign guarded_mmio.reset_n=reset_n;assign guarded_mmio.instance_number=0;
    ia840f_ahls_mmio_completion_guard #(.COMPLETION_SUPPORTED(1)) guard (
        .upstream(mmio),.downstream(guarded_mmio),
        .completion_start(completion_start),.producer_done(producer_done),.access_fault(access_fault),
        .expected_bytes(expected_bytes),.completion_busy(completion_busy),
        .completion_done(completion_done),.completion_errors(completion_errors));
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
        if(b==0) begin : input_bank
            ia840f_ahls_memory_bank_shim #(.ADD_CLOCK_CROSSING(1),.ADD_TIMING_REG_STAGES(3)) shim(
                .to_fiu(physical[b]),.to_afu(bank[b]),.afu_clk(clk),.afu_reset_n(reset_n));
        end else begin : output_bank
            ia840f_ahls_memory_bank_completion_shim #(.ADD_CLOCK_CROSSING(1),.ADD_TIMING_REG_STAGES(3)) shim(
                .to_fiu(physical[b]),.to_afu(bank[b]),.afu_clk(clk),.afu_reset_n(reset_n),
                .completion_start(completion_start),.producer_done(producer_done),.access_fault(access_fault),
                .dma_write_attempt(bank1_dma_write_attempt),.expected_bytes(expected_bytes),
                .completion_busy(completion_busy),.completion_done(completion_done),
                .completion_errors(completion_errors),.accepted_bytes(accepted_bytes));
        end
    end
    ahls_axi_memory_model #(.ENDPOINT(0),.LINEAR_HOST(1),.BASE(HOST_BASE)) host_model(host);
    ahls_axi_memory_model #(.ENDPOINT(1),.BASE(BANK0_BASE)) bank0_model(physical[0]);
    ahls_axi_memory_model #(.ENDPOINT(2),.BASE(BANK1_BASE)) bank1_model(physical[1]);
    ia840f_ahls_memory_core_publication dut (
        .bank1_dma_write_attempt(bank1_dma_write_attempt),
        .clock_reset_clk(clk),
        .clock_reset_reset_reset_n(reset_n),
        .freeze_freeze(1'b0),
        .device_exception_bus_data(exception_unused),
        .kernel_irqs_irq(irq),
        .mmio_control_awid(guarded_mmio.aw.id),
        .mmio_control_awaddr(guarded_mmio.aw.addr),
        .mmio_control_awlen(8'd0),
        .mmio_control_awsize(guarded_mmio.aw.size),
        .mmio_control_awburst(2'b01),
        .mmio_control_awuser(guarded_mmio.aw.user),
        .mmio_control_awvalid(guarded_mmio.awvalid),
        .mmio_control_awready(guarded_mmio.awready),
        .mmio_control_wdata(guarded_mmio.w.data),
        .mmio_control_wstrb(guarded_mmio.w.strb),
        .mmio_control_wvalid(guarded_mmio.wvalid),
        .mmio_control_wuser(guarded_mmio.w.user),
        .mmio_control_wready(guarded_mmio.wready),
        .mmio_control_bid(guarded_mmio.b.id),
        .mmio_control_bresp(guarded_mmio.b.resp),
        .mmio_control_buser(guarded_mmio.b.user),
        .mmio_control_bvalid(guarded_mmio.bvalid),
        .mmio_control_bready(guarded_mmio.bready),
        .mmio_control_arid(guarded_mmio.ar.id),
        .mmio_control_araddr(guarded_mmio.ar.addr),
        .mmio_control_arlen(8'd0),
        .mmio_control_arsize(guarded_mmio.ar.size),
        .mmio_control_arburst(2'b01),
        .mmio_control_aruser(guarded_mmio.ar.user),
        .mmio_control_arvalid(guarded_mmio.arvalid),
        .mmio_control_arready(guarded_mmio.arready),
        .mmio_control_rid(guarded_mmio.r.id),
        .mmio_control_rdata(guarded_mmio.r.data),
        .mmio_control_rresp(guarded_mmio.r.resp),
        .mmio_control_rlast(),
        .mmio_control_rvalid(guarded_mmio.rvalid),
        .mmio_control_rready(guarded_mmio.rready),
        .mmio_control_ruser(guarded_mmio.r.user),
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


    // Accepted original256-bit HLS requests are the independent native-line oracle.
    // These hierarchy names are bound to the freshly generated composition.
`define HLS_NET dut.fabric.fabric.fabric
    always @(posedge clk) begin : source_credit
        longint unsigned a;
        int bytes,offset;
        if(reset_n && kernel_phase)begin
            if(`HLS_NET.k0_avm_mem_gmem0_1_port_0_0_rw_read && !`HLS_NET.k0_avm_mem_gmem0_1_port_0_0_rw_waitrequest)begin
                a=`HLS_NET.k0_avm_mem_gmem0_1_port_0_0_rw_address;
                bytes=int'(`HLS_NET.k0_avm_mem_gmem0_1_port_0_0_rw_burstcount)*32;
                check(bytes>0 && bytes<=256 && a%32==0,"HLS read request shape");
                check((a>=kernel_x && a+bytes<=kernel_x+kernel_read_bytes) ||
                      (a>=kernel_y && a+bytes<=kernel_y+kernel_read_bytes),"HLS read source allocation");
                bank0_model.expect_read_span(a,bytes);hls_reads++;
            end
            if(`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_write && !`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_waitrequest)begin
                if(hls_write_left==0)begin
                    hls_write_base=`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_address;
                    hls_write_left=int'(`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_burstcount);hls_write_index=0;
                    check(hls_write_left>0 && hls_write_left<=8 && hls_write_base%32==0,"HLS write request shape");
                    bank1_model.expect_write_span(hls_write_base,hls_write_left*32);
                end
                a=hls_write_base+32*hls_write_index;
                check(!$isunknown(`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_byteenable),"known HLS mask");
                for(int j=0;j<32;j++)if(`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_byteenable[j])begin
                    check(a+j>=kernel_z && a+j<kernel_z+kernel_output_bytes,"HLS enabled-byte range");
                    offset=int'(a+j-BANK1_BASE);
                    check(`HLS_NET.k0_avm_mem_gmem1_2_port_0_0_rw_writedata[j*8+:8]===bank1_model.expected_storage[offset],"HLS source arithmetic byte");
                end
                hls_write_left--;hls_write_index++;hls_writes++;
            end
        end
    end
`undef HLS_NET

    // Passive coverage at the input of the actual page mapper; no channel drive.
    always @(posedge clk)if(reset_n)begin
        if(bank[0].awvalid && bank[0].awready && bank[0].aw.burst==1 &&
           (int'(bank[0].aw.addr[11:0])+((int'(bank[0].aw.len)+1)<<bank[0].aw.size)>4096))pre_aw_cross0++;
        if(bank[1].awvalid && bank[1].awready && bank[1].aw.burst==1 &&
           (int'(bank[1].aw.addr[11:0])+((int'(bank[1].aw.len)+1)<<bank[1].aw.size)>4096))pre_aw_cross1++;
        if(bank[0].arvalid && bank[0].arready && bank[0].ar.burst==1 &&
           (int'(bank[0].ar.addr[11:0])+((int'(bank[0].ar.len)+1)<<bank[0].ar.size)>4096))pre_ar_cross0++;
        if(bank[1].arvalid && bank[1].arready && bank[1].ar.burst==1 &&
           (int'(bank[1].ar.addr[11:0])+((int'(bank[1].ar.len)+1)<<bank[1].ar.size)>4096))pre_ar_cross1++;

    end

    task automatic check(input logic ok, input string what);
        checks++;
        if (ok !== 1'b1) $fatal(1,"AHLS_PATH_FAIL %s time=%0t",what,$time);
    endtask
    task automatic wr64(input logic[19:0] addr, input logic[63:0] data);
        bit adone,wdone,bdone;
        adone=0;wdone=0;bdone=0;
        @(negedge clk);
        mmio.aw='0;mmio.aw.addr=addr;mmio.aw.size=3;
        mmio.aw.id=16'h31;mmio.aw.user=1;
        mmio.w='0;mmio.w.data=data;mmio.w.strb='1;
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
        mmio.ar.id=16'h52;mmio.ar.user=1;
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
    task automatic begin_memory_phase();
        host_model.begin_phase();bank0_model.begin_phase();bank1_model.begin_phase();
    endtask
    task automatic dma_copy(input longint unsigned src,dst,input int beats,mode);
        logic [63:0] before_status,st;
        longint unsigned local_addr;
        int next_count,which,idx;
        bit done;
        begin_memory_phase();check(beats>0,"positive descriptor credit");
        if(mode==1)begin
            which=int'((dst>>34)&1);local_addr=dst&BANK_MASK;
            host_model.allow_read(src,beats*64);host_model.expect_read_span(src,beats*64);
            if(which==0)begin
                bank0_model.allow_write(local_addr,beats*64);bank0_model.expect_write_span(local_addr,beats*64);
                for(int j=0;j<beats*64;j++)bank0_model.expect_byte(local_addr+j,host_model.storage[int'(src-HOST_BASE)+j]);
            end else begin
                bank1_model.allow_write(local_addr,beats*64);bank1_model.expect_write_span(local_addr,beats*64);
                for(int j=0;j<beats*64;j++)bank1_model.expect_byte(local_addr+j,host_model.storage[int'(src-HOST_BASE)+j]);
            end
        end else begin
            check(mode==2,"DMA direction");which=int'((src>>34)&1);local_addr=src&BANK_MASK;
            host_model.allow_write(dst,beats*64);host_model.expect_write_span(dst,beats*64);
            if(which==0)begin
                bank0_model.allow_read(local_addr,beats*64);bank0_model.expect_read_span(local_addr,beats*64);
                for(int j=0;j<beats*64;j++)host_model.expect_byte(dst+j,bank0_model.expected_storage[int'(local_addr-BANK0_BASE)+j]);
            end else begin
                bank1_model.allow_read(local_addr,beats*64);bank1_model.expect_read_span(local_addr,beats*64);
                for(int j=0;j<beats*64;j++)host_model.expect_byte(dst+j,bank1_model.expected_storage[int'(local_addr-BANK1_BASE)+j]);
            end
        end
        rd64(20'h48,before_status);next_count=(before_status[31:28]+1)&15;
        wr64(20'h28,src);wr64(20'h30,dst);wr64(20'h38,beats);
        wr64(20'h40,64'h80000000|(64'(mode)<<26));
        done=0;
        for(int t=0;t<2000;t++)begin
            rd64(20'h48,st);check(!st[13]&&!st[10]&&!st[7],$sformatf("DMA status=%h",st));
            if(st[31:28]==next_count && !st[0] && st[1])begin done=1;break;end
        end
        check(done,"DMA completion timeout");
        if(mode==1)begin
            host_model.check_reads_complete();
            if(which==0)bank0_model.check_writes_complete(beats*64);else bank1_model.check_writes_complete(beats*64);
        end else begin
            host_model.check_writes_complete(beats*64);
            if(which==0)bank0_model.check_reads_complete();else bank1_model.check_reads_complete();
        end
        dma_completed++;
    endtask
    function automatic int xvalue(input int c,i);return -137+((i*17+c*13)%251);endfunction
    function automatic int yvalue(input int c,i);return 93-((i*i*7+c*11)%197);endfunction
    function automatic byte unsigned sentinel(input longint unsigned a,input int c);
        longint unsigned v;
        v=a ^ 64'hd1b54a32d192ed03 ^ (64'(c)<<17);
        v^=v>>30;v*=64'hbf58476d1ce4e5b9;v^=v>>27;v*=64'h94d049bb133111eb;v^=v>>31;
        return byte'(v);
    endfunction
    task automatic run_case(input int c,n);
        int beats,copy_bytes,expected,lane,idx,shift,xbase,ybase,zfloor,zguard,payload_offset;
        logic [63:0] st,fin;
        byte unsigned want;
        bit done,published;
        shift=(c&1)*32;kernel_read_bytes=((n+7)/8)*32;beats=(shift+kernel_read_bytes+63)/64;copy_bytes=(beats+2)*64;
        xbase=c>=3?'h1fc0:'h1000;ybase=c>=3?'h2fc0:'h2000;zfloor=c>=3?'h4fc0:'h4000;zguard=zfloor-64;payload_offset=64+shift;
        kernel_x=BANK0_BASE+xbase+shift;kernel_y=BANK0_BASE+ybase+shift;kernel_z=BANK1_BASE+zfloor+shift;kernel_output_bytes=n*4;
        $display("FPGA Test integrated case=%0d n=%0d shift=%0d x=%h y=%h z=%h",c,n,shift,kernel_x,kernel_y,kernel_z);
        for(int j=0;j<beats*64;j++)begin
            host_model.storage['h1000+j]=sentinel(HOST_BASE+'h1000+j,c);
            host_model.storage['h2000+j]=sentinel(HOST_BASE+'h2000+j,c);
        end
        for(int j=0;j<copy_bytes;j++)begin
            host_model.storage['h3000+j]=sentinel(BANK1_BASE+zguard+j,c);
            host_model.storage['h4000+j]=~sentinel(BANK1_BASE+zguard+j,c);
        end
        for(int i=0;i<n;i++)begin
            host_model.write_int('h1000+shift+i*4,xvalue(c,i));host_model.write_int('h2000+shift+i*4,yvalue(c,i));
        end
        for(int j=0;j<65536;j++)host_expected[j]=host_model.storage[j];
        bank1_model.response_delay_cycles=11;
        dma_copy(HOST_BASE+'h1000,BANK0_BASE+xbase,beats,1);
        dma_copy(HOST_BASE+'h2000,BANK0_BASE+ybase,beats,1);
        dma_copy(HOST_BASE+'h3000,(64'd1<<34)|(BANK1_BASE+zguard),beats+2,1);
        rd64(20'h10030,fin);repeat(10)@(negedge clk);
        rd64(20'h10030,fin);check(fin===0,"finish baseline");
        rd64(20'h10000,st);check(st[31:16]===16'd5 && (st&64'hb007)==0,"kernel clean baseline");
        begin_memory_phase();
        bank0_model.allow_read(BANK0_BASE+xbase,beats*64);bank0_model.allow_read(BANK0_BASE+ybase,beats*64);
        bank1_model.allow_write(BANK1_BASE+zguard,copy_bytes);
        for(int i=0;i<n;i++)begin
            expected=xvalue(c,i)+yvalue(c,i);
            for(int j=0;j<4;j++)bank1_model.expect_byte(kernel_z+4*i+j,expected[j*8+:8]);
        end
        bank1_model.response_delay_cycles=200;
        @(negedge clk);kernel_phase=1;hls_write_left=0;
        wr64(20'h10080,kernel_x);wr64(20'h10088,kernel_y);wr64(20'h10090,kernel_z);wr64(20'h10098,n);wr64(20'h10008,1);
        done=0;
        for(int t=0;t<2000;t++)begin rd64(20'h10000,st);if((st&64'hb007)==2)begin done=1;break;end end
        check(done,"HLS completion timeout");if(!completion_done)early_finish_cases++;
        rd64(20'h10030,fin);check(fin===1,"fresh finish ticket");
        published=0;
        for(int t=0;t<2000;t++)begin
            rd64(20'h20028,st);pub_snapshots++;
            check(st[16] && st[15:8]==0,"completion supported and error-free");
            if(st[1] && !st[0])begin published=1;break;end
        end
        check(published,"finite output and response retirement timeout");
        check(accepted_bytes==64'(n)*4,"exact enabled output byte credit");
        check(bank1_model.accepted_reference_bytes==kernel_output_bytes,"completion has complete source credit");
        check(bank1_model.aw_count==bank1_model.b_count && !bank1_model.wr_active && !bank1_model.b_pending && !physical[1].bvalid,"completion not ahead of native responses");
        pub_certificate_checks++;
        // These are post-gate assertions, never the operation's wait/fence condition.
        bank1_model.check_writes_complete(n*4);bank0_model.check_reads_complete();check(hls_write_left==0,"complete original HLS write burst");
        @(negedge clk);kernel_phase=0;
        dma_copy((64'd1<<34)|(BANK1_BASE+zguard),HOST_BASE+'h4000,beats+2,2);
        for(int i=0;i<n;i++)begin
            expected=xvalue(c,i)+yvalue(c,i);
            check(host_model.read_int('h4000+payload_offset+4*i)===expected,$sformatf("numeric c=%0d i=%0d",c,i));checked_elements++;
        end
        for(int j=0;j<copy_bytes;j++)begin
            if(j>=payload_offset && j<payload_offset+n*4)begin
                idx=(j-payload_offset)/4;lane=(j-payload_offset)%4;expected=xvalue(c,idx)+yvalue(c,idx);want=expected[lane*8+:8];
            end else want=sentinel(BANK1_BASE+zguard+j,c);
            check(host_model.storage['h4000+j]===want,$sformatf("copyback/guard c=%0d byte=%0d",c,j));host_expected['h4000+j]=want;checked_bytes++;
        end
        for(int j=0;j<65536;j++)check(host_model.storage[j]===host_expected[j],"complete host source/guard memory");
        completed_cases++;
        $display("FPGA Test integrated case PASS id=%0d n=%0d",c,n);
    endtask
    initial begin
        mmio.aw='0;mmio.w='0;mmio.ar='0;
        mmio.awvalid=0;mmio.wvalid=0;mmio.bready=0;mmio.arvalid=0;mmio.rready=0;
        repeat(200) @(negedge clk);reset_n=1;
        repeat(200) @(negedge clk);
        run_case(0,1);run_case(1,8);run_case(2,17);run_case(3,65);run_case(4,9);run_case(5,33);
        check(bank0_model.last_w_stalls>0 && bank1_model.last_w_stalls>0,"forced final-W stall coverage");
        check(early_finish_cases>0,"HLS finish before native retirement exercised");
        check(pre_aw_cross0>0 && pre_aw_cross1>0,"actual page-split write input coverage on both banks");
        $display("PAGE_CROSSING_INPUTS AW0=%0d AW1=%0d AR0=%0d AR1=%0d",pre_aw_cross0,pre_aw_cross1,pre_ar_cross0,pre_ar_cross1);
        check(pub_certificate_checks==completed_cases,"retirement certificate check hit every case");
        $display("RETIREMENT_CERTIFICATE_CHECKS count=%0d",pub_certificate_checks);
        $display("INTEGRATED_COVERAGE hls_reads=%0d hls_writes=%0d early_finish=%0d snapshots=%0d bank0_lastW=%0d bank1_lastW=%0d bank0_ARstall=%0d bank1_ARstall=%0d bank0_Bhold=%0d bank1_Bhold=%0d",hls_reads,hls_writes,early_finish_cases,pub_snapshots,bank0_model.last_w_stalls,bank1_model.last_w_stalls,bank0_model.ar_stalls,bank1_model.ar_stalls,bank0_model.b_stalls,bank1_model.b_stalls);
        $display("AHLS_PATH_UNIT_PASS cases=%0d elements=%0d copied_bytes=%0d dma=%0d checks=%0d mmio_reads=%0d mmio_writes=%0d bank0_W=%0d bank1_W=%0d",completed_cases,checked_elements,checked_bytes,dma_completed,checks,mmio_reads,mmio_writes,bank0_model.w_count,bank1_model.w_count);
        $finish;
    end
    initial begin #10000000;$fatal(1,"AHLS_PATH_FAIL simulation watchdog");end
endmodule

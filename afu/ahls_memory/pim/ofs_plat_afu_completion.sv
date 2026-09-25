// CAPS03 completion candidate, not deployed. IA840F memory AFU: actual PIM + page-safe banks + full-address MMIO guard.
// Architecture reference: pinned AI Suite OFS primary-host/per-bank shims.
// Separate source list from the existing scalar ofs_plat_afu; never compile both.
`include "ofs_plat_if.vh"
module ofs_plat_afu (ofs_plat_if plat_ifc);
    wire core_clk = plat_ifc.local_mem.banks[0].clk;
    wire core_reset_n;
    // Join both bank resets and soft reset using the unchanged PIM primitive.
    ia840f_ahls_memory_reset application_reset (
        .core_clk(core_clk), .bank0_reset_n(plat_ifc.local_mem.banks[0].reset_n),
        .host_clk(plat_ifc.clocks.pClk.clk), .soft_reset_n(plat_ifc.softReset_n),
        .bank1_clk(plat_ifc.local_mem.banks[1].clk),
        .bank1_reset_n(plat_ifc.local_mem.banks[1].reset_n), .core_reset_n(core_reset_n));
    wire core_freeze;
    ofs_plat_prim_clock_crossing_reg #(.WIDTH(1),.INITIAL_VALUE(1'b1)) freeze_cc (
        .clk_src(plat_ifc.clocks.pClk.clk), .clk_dst(core_clk),
        .r_in(plat_ifc.pr_freeze_to_afu_in), .r_out(core_freeze));

    ofs_plat_axi_mem_if #(`HOST_CHAN_AXI_MEM_PARAMS,
        .BURST_CNT_WIDTH(8), .RID_WIDTH(9), .WID_WIDTH(9), .USER_WIDTH(4)) host_mem();
    ofs_plat_axi_mem_lite_if #(
        .ADDR_WIDTH(ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES), .DATA_WIDTH(64),
        .RID_WIDTH(16), .WID_WIDTH(16), .USER_WIDTH(1)) mmio();
    ofs_plat_host_chan_as_axi_mem_with_mmio #(
        .SORT_READ_RESPONSES(1), .SORT_WRITE_RESPONSES(1),
        .BUFFER_READ_RESPONSES(1), .ADD_CLOCK_CROSSING(1), .ADD_TIMING_REG_STAGES(3)) primary_axi (
        .to_fiu(plat_ifc.host_chan.ports[0]), .host_mem_to_afu(host_mem),
        .mmio_to_afu(mmio), .afu_clk(core_clk), .afu_reset_n(core_reset_n));

    // Keep the full 20-bit MMIO address until admission, before PD decoding.
    // The guard is not a CDC: both interfaces share the primary PIM domain.
    ofs_plat_axi_mem_lite_if #(
        .ADDR_WIDTH(ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES), .DATA_WIDTH(64),
        .RID_WIDTH(16), .WID_WIDTH(16), .USER_WIDTH(1)) guarded_mmio();
    assign guarded_mmio.clk = mmio.clk;
    assign guarded_mmio.reset_n = mmio.reset_n;
    assign guarded_mmio.instance_number = mmio.instance_number;
    wire bank1_dma_write_attempt;
    wire completion_start, producer_done, access_fault, completion_busy, completion_done;
    wire [7:0] completion_errors;
    wire [32:0] expected_bytes, accepted_bytes;
    ia840f_ahls_mmio_completion_guard #(.COMPLETION_SUPPORTED(0)) completion_guard (
        .upstream(mmio), .downstream(guarded_mmio),
        .completion_start(completion_start), .producer_done(producer_done), .access_fault(access_fault),
        .expected_bytes(expected_bytes), .completion_busy(completion_busy),
        .completion_done(completion_done), .completion_errors(completion_errors));

    // Expanded arbitration IDs are retained by the PIM user_ext mapper,
    // not truncated to the physical memory controller's nine-bit IDs.
    ofs_plat_axi_mem_if #(
        .ADDR_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_BYTE_ADDR_WIDTH),
        .DATA_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_DATA_WIDTH),
        .BURST_CNT_WIDTH(8), .RID_WIDTH(18), .WID_WIDTH(18),
        .USER_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_USER_WIDTH)) banks[2]();
    for (genvar b=0; b<2; b++) begin : map_banks
        if(b==0) begin : input_bank
            ia840f_ahls_memory_bank_shim #(.ADD_CLOCK_CROSSING(1),
                .ADD_TIMING_REG_STAGES(3)) shim (
                .to_fiu(plat_ifc.local_mem.banks[b]), .to_afu(banks[b]),
                .afu_clk(core_clk), .afu_reset_n(core_reset_n));
        end else begin : output_bank
            ia840f_ahls_memory_bank_completion_shim #(.ADD_CLOCK_CROSSING(1),
                .ADD_TIMING_REG_STAGES(3)) shim (
                .to_fiu(plat_ifc.local_mem.banks[b]), .to_afu(banks[b]),
                .afu_clk(core_clk), .afu_reset_n(core_reset_n),
                .completion_start(completion_start), .producer_done(producer_done),
                .access_fault(access_fault), .dma_write_attempt(bank1_dma_write_attempt),
                .expected_bytes(expected_bytes), .completion_busy(completion_busy),
                .completion_done(completion_done), .completion_errors(completion_errors),
                .accepted_bytes(accepted_bytes));
        end
        assign banks[b].aw.atop = '0;
    end
    ofs_plat_if_tie_off_unused #(.HOST_CHAN_IN_USE_MASK(1),
        .LOCAL_MEM_IN_USE_MASK(2'b11)) tie_off(plat_ifc);

    // Exact static geometry rejects silent narrowing at the flat core boundary.
    if (ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES != 20 ||
        ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES != 57 ||
        ofs_plat_host_chan_pkg::DATA_WIDTH != 512 ||
        local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS != 2 ||
        local_mem_cfg_pkg::LOCAL_MEM_BYTE_ADDR_WIDTH != 34 ||
        local_mem_cfg_pkg::LOCAL_MEM_DATA_WIDTH != 512 ||
        local_mem_cfg_pkg::LOCAL_MEM_USER_WIDTH != 2 ||
        $bits(ofs_plat_host_chan_pcie_tlp_pkg::t_mmio_rd_tag)+1 > 16) begin : reject_geometry
        IA840F_UNSUPPORTED_PIM_GEOMETRY fail_closed();
    end
    wire kernel_irq_unrouted;
    wire [63:0] kernel_exception_not_checker;
    wire mmio_single_rlast;
    // Full-address admission is present; PCIe ordering/global drain/reset/PR are open.
    // This structural checkpoint is not a deployable or hardware-qualified AFU.
    ia840f_ahls_memory_core_publication core (
        .bank1_dma_write_attempt(bank1_dma_write_attempt),
        .clock_reset_clk(core_clk),
        .clock_reset_reset_reset_n(core_reset_n),
        .freeze_freeze(core_freeze),
        .device_exception_bus_data(kernel_exception_not_checker),
        .kernel_irqs_irq(kernel_irq_unrouted),
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
        .mmio_control_rlast(mmio_single_rlast),
        .mmio_control_rvalid(guarded_mmio.rvalid),
        .mmio_control_rready(guarded_mmio.rready),
        .mmio_control_ruser(guarded_mmio.r.user),
        .bank_out0_awid(banks[0].aw.id),
        .bank_out0_awaddr(banks[0].aw.addr),
        .bank_out0_awlen(banks[0].aw.len),
        .bank_out0_awsize(banks[0].aw.size),
        .bank_out0_awburst(banks[0].aw.burst),
        .bank_out0_awlock(banks[0].aw.lock),
        .bank_out0_awcache(banks[0].aw.cache),
        .bank_out0_awprot(banks[0].aw.prot),
        .bank_out0_awuser(banks[0].aw.user),
        .bank_out0_awqos(banks[0].aw.qos),
        .bank_out0_awregion(banks[0].aw.region),
        .bank_out0_awvalid(banks[0].awvalid),
        .bank_out0_awready(banks[0].awready),
        .bank_out0_wdata(banks[0].w.data),
        .bank_out0_wstrb(banks[0].w.strb),
        .bank_out0_wlast(banks[0].w.last),
        .bank_out0_wvalid(banks[0].wvalid),
        .bank_out0_wuser(banks[0].w.user),
        .bank_out0_wready(banks[0].wready),
        .bank_out0_bid(banks[0].b.id),
        .bank_out0_bresp(banks[0].b.resp),
        .bank_out0_buser(banks[0].b.user),
        .bank_out0_bvalid(banks[0].bvalid),
        .bank_out0_bready(banks[0].bready),
        .bank_out0_arid(banks[0].ar.id),
        .bank_out0_araddr(banks[0].ar.addr),
        .bank_out0_arlen(banks[0].ar.len),
        .bank_out0_arsize(banks[0].ar.size),
        .bank_out0_arburst(banks[0].ar.burst),
        .bank_out0_arlock(banks[0].ar.lock),
        .bank_out0_arcache(banks[0].ar.cache),
        .bank_out0_arprot(banks[0].ar.prot),
        .bank_out0_aruser(banks[0].ar.user),
        .bank_out0_arqos(banks[0].ar.qos),
        .bank_out0_arregion(banks[0].ar.region),
        .bank_out0_arvalid(banks[0].arvalid),
        .bank_out0_arready(banks[0].arready),
        .bank_out0_rid(banks[0].r.id),
        .bank_out0_rdata(banks[0].r.data),
        .bank_out0_rresp(banks[0].r.resp),
        .bank_out0_rlast(banks[0].r.last),
        .bank_out0_rvalid(banks[0].rvalid),
        .bank_out0_rready(banks[0].rready),
        .bank_out0_ruser(banks[0].r.user),
        .bank_out1_awid(banks[1].aw.id),
        .bank_out1_awaddr(banks[1].aw.addr),
        .bank_out1_awlen(banks[1].aw.len),
        .bank_out1_awsize(banks[1].aw.size),
        .bank_out1_awburst(banks[1].aw.burst),
        .bank_out1_awlock(banks[1].aw.lock),
        .bank_out1_awcache(banks[1].aw.cache),
        .bank_out1_awprot(banks[1].aw.prot),
        .bank_out1_awuser(banks[1].aw.user),
        .bank_out1_awqos(banks[1].aw.qos),
        .bank_out1_awregion(banks[1].aw.region),
        .bank_out1_awvalid(banks[1].awvalid),
        .bank_out1_awready(banks[1].awready),
        .bank_out1_wdata(banks[1].w.data),
        .bank_out1_wstrb(banks[1].w.strb),
        .bank_out1_wlast(banks[1].w.last),
        .bank_out1_wvalid(banks[1].wvalid),
        .bank_out1_wuser(banks[1].w.user),
        .bank_out1_wready(banks[1].wready),
        .bank_out1_bid(banks[1].b.id),
        .bank_out1_bresp(banks[1].b.resp),
        .bank_out1_buser(banks[1].b.user),
        .bank_out1_bvalid(banks[1].bvalid),
        .bank_out1_bready(banks[1].bready),
        .bank_out1_arid(banks[1].ar.id),
        .bank_out1_araddr(banks[1].ar.addr),
        .bank_out1_arlen(banks[1].ar.len),
        .bank_out1_arsize(banks[1].ar.size),
        .bank_out1_arburst(banks[1].ar.burst),
        .bank_out1_arlock(banks[1].ar.lock),
        .bank_out1_arcache(banks[1].ar.cache),
        .bank_out1_arprot(banks[1].ar.prot),
        .bank_out1_aruser(banks[1].ar.user),
        .bank_out1_arqos(banks[1].ar.qos),
        .bank_out1_arregion(banks[1].ar.region),
        .bank_out1_arvalid(banks[1].arvalid),
        .bank_out1_arready(banks[1].arready),
        .bank_out1_rid(banks[1].r.id),
        .bank_out1_rdata(banks[1].r.data),
        .bank_out1_rresp(banks[1].r.resp),
        .bank_out1_rlast(banks[1].r.last),
        .bank_out1_rvalid(banks[1].rvalid),
        .bank_out1_rready(banks[1].rready),
        .bank_out1_ruser(banks[1].r.user),
        .host_awid(host_mem.aw.id),
        .host_awaddr(host_mem.aw.addr),
        .host_awlen(host_mem.aw.len),
        .host_awsize(host_mem.aw.size),
        .host_awburst(host_mem.aw.burst),
        .host_awlock(host_mem.aw.lock),
        .host_awcache(host_mem.aw.cache),
        .host_awprot(host_mem.aw.prot),
        .host_awuser(host_mem.aw.user),
        .host_awqos(host_mem.aw.qos),
        .host_awregion(host_mem.aw.region),
        .host_awatop(host_mem.aw.atop),
        .host_awvalid(host_mem.awvalid),
        .host_awready(host_mem.awready),
        .host_arid(host_mem.ar.id),
        .host_araddr(host_mem.ar.addr),
        .host_arlen(host_mem.ar.len),
        .host_arsize(host_mem.ar.size),
        .host_arburst(host_mem.ar.burst),
        .host_arlock(host_mem.ar.lock),
        .host_arcache(host_mem.ar.cache),
        .host_arprot(host_mem.ar.prot),
        .host_aruser(host_mem.ar.user),
        .host_arqos(host_mem.ar.qos),
        .host_arregion(host_mem.ar.region),
        .host_arvalid(host_mem.arvalid),
        .host_arready(host_mem.arready),
        .host_wdata(host_mem.w.data),
        .host_wstrb(host_mem.w.strb),
        .host_wlast(host_mem.w.last),
        .host_wuser(host_mem.w.user),
        .host_wvalid(host_mem.wvalid),
        .host_wready(host_mem.wready),
        .host_rid(host_mem.r.id),
        .host_rdata(host_mem.r.data),
        .host_rresp(host_mem.r.resp),
        .host_rlast(host_mem.r.last),
        .host_ruser(host_mem.r.user),
        .host_rvalid(host_mem.rvalid),
        .host_rready(host_mem.rready),
        .host_bid(host_mem.b.id),
        .host_bresp(host_mem.b.resp),
        .host_buser(host_mem.b.user),
        .host_bvalid(host_mem.bvalid),
        .host_bready(host_mem.bready)
    );
endmodule

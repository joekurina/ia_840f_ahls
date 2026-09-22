// AHLS qualification AFU top for the IA840F OFS PR slot (PIM mode).
// Copyright (C) 2026. SPDX-License-Identifier: MIT.
//
// Qualification evidence: N/qualification/ahls-afu-fim-01/report.md
//
// Donors (exact reference files in this tree):
//   - examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/hw/rtl/avalon/
//       ofs_plat_afu.sv + hello_world_avalon.sv   (CSR-only PIM AFU shape;
//       DFH/UUID words 0-4; `AFU_ACCEL_UUID from afu_json_info.vh)
//   - examples-afu/tutorial/afu_types/01_pim_ifc/local_memory/hw/rtl/avalon/
//       ofs_plat_afu.sv  (ofs_plat_afu top shape; per-bank shims; tie-off)
//   - ofs-agx7-pcie-attach/ofs-common/src/common/he_lb/pr_example/ofs_plat_afu/
//       ofs_plat_afu.sv  (in-tree precedent for a PIM-wrapped PR AFU)
//   - afu/ahls/rtl/ahls_board_binding.sv  (reusable binding entry; contract
//       afu/ahls/integration-contract.json)
//
// Generated component: qual_vec_op.report.prj/qual_vec_op_report_di.sv
//   (HLS IP Gen 2026.1.0, ahls-compile-01; Quartus 26.1.1 import proven in
//    ahls-qsys-import-01: byte-identical top RTL, rc=0 generation).
//
// Module name is fixed by the generated platform:
//   afu_with_pim/afu/build/platform/platform_afu_top_config.vh:
//     `define PLATFORM_SHIM_MODULE_NAME ofs_plat_afu
//   ofs-common/.../afu_main_pim/port_afu_instances.sv instantiates
//   `PLATFORM_SHIM_MODULE_NAME with a single ofs_plat_if port. afu_main.tcl
//   selects that instantiation path when afu_with_pim/afu.tcl exists.
//
// Structure:
//   plat_ifc -> ahls_board_binding (PIM shims + DFH/UUID aperture + rebased
//   64-bit Avalon CSR agent) -> qual_vec_op_report_di (AHLS kernel CSRs).
//   Host-memory and both local-memory byte agents are instantiated with the
//   binding's required byte-address geometry but held permanently
//   request-idle: this qualification AFU has no DMA/host-pipe path, and none
//   is invented (binding contract "limits"). The binding performs the
//   platform tie-off internally (ofs_plat_if_tie_off_unused); no competing
//   tie-off is instantiated here.
//
// Clock/reset: ahls_ofs_board_services crosses host-chan port 0 and both
// banks into the uClk_usrDiv2 domain and exports binding_clk/binding_reset_n,
// which drive the AHLS component clock/resetn. The kernel logic is fully
// synchronous and exercises only CSR control traffic in this AFU.

`include "ofs_plat_if.vh"
`include "afu_json_info.vh"

module ofs_plat_afu
   (
    // All platform wires, wrapped in one interface.
    ofs_plat_if plat_ifc
    );

    // ====================================================================
    //  Identity (must match the AFU JSON and afu_json_info.vh exactly)
    // ====================================================================
    // UUID 67bc266a-56f7-440a-bb75-12b5f446d842 (afu_json_mgr packing:
    // 128'h + hyphens->underscores, verified live).
    localparam logic [127:0] AFU_UUID = `AFU_ACCEL_UUID;

    // ====================================================================
    //  Binding parameters (aperture math: report.md "Aperture")
    // ====================================================================
    // ahls_mmio_aperture serves DFH/UUID at words 0-4 (bytes 0x00-0x27) and
    // requires CSR_BASE_BYTES >= 40. The generated kernel register map spans
    // 0x00-0x97 (status/start/finish/args/ResultPipe;
    // IDQualVecOp_register_map.h), decoded by the component as a 5-bit word
    // address over a 256-byte span (Avalon addressUnits WORDS, addressSpan
    // 256; qual_test_k0.ip). Choosing:
    //   CSR_BASE_BYTES = 0x40  (64B-aligned, first word after DFH reserved
    //                            hole; words 5-7 remain decode-error)
    //   CSR_SIZE_BYTES = 0x100 (256 B = 32 words = exactly the 5-bit
    //                            component word-address space)
    // Host-visible kernel register offsets = 0x40 + kernel-map offset
    // (status 0x40, start 0x48, finish 0x70, args 0xC0/0xC8, ResultPipe 0xD0).
    localparam int unsigned CSR_BASE_BYTES = 64;   // 0x40
    localparam int unsigned CSR_SIZE_BYTES = 256;  // 0x100

    localparam int NUM_LOCAL_MEM_BANKS = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS; // 2 on IA840F

    // Binding CSR agent width: byte-addressed MMIO agent. On this platform
    // MMIO_ADDR_WIDTH_BYTES = 20 (VF BAR0 2 MiB) so CSR_BYTE_ADDR_WIDTH = 20
    // and in-aperture byte addresses are 0x40..0x13F (csr_address[19:8]==0).
    localparam int CSR_BYTE_ADDR_WIDTH = ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES;

    // ====================================================================
    //  Binding CSR agent wires
    // ====================================================================
    logic [CSR_BYTE_ADDR_WIDTH-1:0] csr_address;
    logic                           csr_read;
    logic                           csr_write;
    logic [63:0]                    csr_writedata;
    logic [7:0]                     csr_byteenable;
    logic                           csr_waitrequest;
    logic [63:0]                    csr_readdata;
    logic                           csr_readdatavalid;
    logic [1:0]                     csr_response;
    logic                           csr_unsupported_request;

    logic binding_clk;
    logic binding_reset_n;

    // ====================================================================
    //  Memory-side byte agents (binding boundary; request-idle)
    // ====================================================================
    // The binding's host_bytes/local_bytes ports are unspecialized; this top
    // must give them exact byte-address geometry. The binding converts
    // byte->line internally (ahls_avmm_byte_to_line) and derives its line
    // interface params from these instances:
    //   host:  ADDR_WIDTH = ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES
    //          (51 line bits + 6 = 57), DATA_WIDTH 512, USER_WIDTH =
    //          HC_AVALON_UFLAG_WITH_VCHAN_WIDTH (14; the PIM host-chan Avalon
    //          shim fatal-checks that the user field fits flags+vchan, and
    //          the binding fatal-checks USER_WIDTH > HC_AVALON_UFLAG_MAX).
    //   local: ADDR_WIDTH = LOCAL_MEM_BYTE_ADDR_WIDTH (28 line + 6 = 34),
    //          DATA_WIDTH 512, BURST_CNT_WIDTH = LOCAL_MEM_BURST_CNT_WIDTH,
    //          USER_WIDTH = LOCAL_MEM_USER_WIDTH, matching the geometry the
    //          per-bank shim's to_afu side expects after line conversion.
    ofs_plat_avalon_mem_if #(
        .ADDR_WIDTH(ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES),
        .DATA_WIDTH(ofs_plat_host_chan_pkg::DATA_WIDTH),
        .USER_WIDTH(ofs_plat_host_chan_avalon_mem_pkg::HC_AVALON_UFLAG_WITH_VCHAN_WIDTH),
        .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN)
    ) host_bytes();

    ofs_plat_avalon_mem_if #(
        .ADDR_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_BYTE_ADDR_WIDTH),
        .DATA_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_DATA_WIDTH),
        .BURST_CNT_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_BURST_CNT_WIDTH),
        .USER_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_USER_WIDTH),
        .LOG_CLASS(ofs_plat_log_pkg::LOCAL_MEM)
    ) local_bytes[NUM_LOCAL_MEM_BANKS]();

    // This qualification AFU issues no host-memory or local-memory requests
    // (no DMA engine / host pipe in scope; binding contract limits). Master
    // side tied request-idle: read/write low, responses never issued from
    // this side. The binding still supplies clk/reset/instance_number from
    // its internal shims and services the platform tie-off. Alignment-fault
    // outputs stay deasserted (no requests); they are deliberately
    // unconnected (no consumer in this AFU).
    assign host_bytes.read = 1'b0;
    assign host_bytes.write = 1'b0;
    assign host_bytes.address = '0;
    assign host_bytes.burstcount = '0;
    assign host_bytes.writedata = '0;
    assign host_bytes.byteenable = '0;
    assign host_bytes.user = '0;

    for (genvar b = 0; b < NUM_LOCAL_MEM_BANKS; b++) begin : local_bytes_idle
        assign local_bytes[b].read = 1'b0;
        assign local_bytes[b].write = 1'b0;
        assign local_bytes[b].address = '0;
        assign local_bytes[b].burstcount = '0;
        assign local_bytes[b].writedata = '0;
        assign local_bytes[b].byteenable = '0;
        assign local_bytes[b].user = '0;
    end

    // ====================================================================
    //  Board binding
    // ====================================================================
    ahls_board_binding #(
        .AFU_UUID(AFU_UUID),
        .CSR_BASE_BYTES(CSR_BASE_BYTES),
        .CSR_SIZE_BYTES(CSR_SIZE_BYTES),
        .NUM_LOCAL_MEM_BANKS(NUM_LOCAL_MEM_BANKS),
        .CSR_BYTE_ADDR_WIDTH(CSR_BYTE_ADDR_WIDTH)
    ) ahls_binding (
        .plat_ifc(plat_ifc),
        .host_bytes(host_bytes),
        .local_bytes(local_bytes),
        .host_address_alignment_fault(),
        .local_address_alignment_fault(),
        .binding_clk(binding_clk),
        .binding_reset_n(binding_reset_n),
        .csr_address(csr_address),
        .csr_read(csr_read),
        .csr_write(csr_write),
        .csr_writedata(csr_writedata),
        .csr_byteenable(csr_byteenable),
        .csr_waitrequest(csr_waitrequest),
        .csr_readdata(csr_readdata),
        .csr_readdatavalid(csr_readdatavalid),
        .csr_response(csr_response),
        .csr_unsupported_request(csr_unsupported_request)
    );

    // ====================================================================
    //  AHLS-generated component (kernel IDQualVecOp)
    // ====================================================================
    // Port list is the actual generated interface (qual_vec_op_report_di.sv /
    // qual_test_k0.ip), not a guessed wrapper:
    //   clock, resetn (active-low), freeze (conduit; tied inactive here --
    //   the PIM plat_ifc exposes no PR-freeze line to the AFU; report risk),
    //   device_exception_bus[63:0] and kernel_irqs (unconnected: no PIM
    //   interrupt routing is bound by the reusable library; report risk),
    //   csr_ring_root_avs: Avalon slave, 5-bit word address, 64-bit data,
    //   byteenable[7:0], waitrequest/readdata/readdatavalid.
    // csr_ring_root_avs_enable is a generated dummy port carried only for
    // Platform Designer bind compatibility ("dummy ports : for bind_port
    // compatibility with AVS signals in the System Integrator",
    // ip/cra_ring_root.sv line 39); tied inactive.
    // csr_response: the generated agent has no response channel; OKAY (0)
    // tied, consistent with the aperture's DECODEERROR=3 outside the window.
    // Address binding: in-aperture rebased byte addresses 0x40..0x13F make
    // csr_address[7:3] the component's word address (bits [19:8] are always
    // zero in-aperture; lossless by construction of the aperture window).
    qual_vec_op_report_di qual_vec_op_k0 (
        .clock(binding_clk),
        .resetn(binding_reset_n),
        .freeze(1'b0),
        .device_exception_bus(),
        .kernel_irqs(),
        .csr_ring_root_avs_enable(1'b0),
        .csr_ring_root_avs_read(csr_read),
        .csr_ring_root_avs_write(csr_write),
        .csr_ring_root_avs_address(csr_address[7:3]),
        .csr_ring_root_avs_writedata(csr_writedata),
        .csr_ring_root_avs_byteenable(csr_byteenable),
        .csr_ring_root_avs_waitrequest(csr_waitrequest),
        .csr_ring_root_avs_readdata(csr_readdata),
        .csr_ring_root_avs_readdatavalid(csr_readdatavalid)
    );

    assign csr_response = 2'b00;

    // ====================================================================
    //  Elaboration-time geometry checks (mirror the binding library's own
    //  checks for the parameters chosen in this top; fire in sim/elab)
    // ====================================================================
    initial begin
        if (AFU_UUID != 128'h67bc266a_56f7_440a_bb75_12b5f446d842)
            $fatal(1, "AFU_UUID does not match the reviewed qualification UUID 67bc266a-56f7-440a-bb75-12b5f446d842");
        if (NUM_LOCAL_MEM_BANKS != 2)
            $fatal(1, "IA840F platform provides exactly 2 local memory banks");
        if (CSR_BYTE_ADDR_WIDTH != 20)
            $fatal(1, "Unexpected MMIO byte address width (expected VF BAR0 20-bit)");
        if (CSR_BASE_BYTES != 64 || CSR_SIZE_BYTES != 256)
            $fatal(1, "Aperture parameters drifted from the reviewed qual values");
        if (host_bytes.ADDR_WIDTH != ofs_plat_host_chan_pkg::ADDR_WIDTH_LINES + 6)
            $fatal(1, "host_bytes must be byte-addressed (line width + 6)");
        if (local_bytes[0].ADDR_WIDTH != local_mem_cfg_pkg::LOCAL_MEM_ADDR_WIDTH + 6)
            $fatal(1, "local_bytes must be byte-addressed (line width + 6)");
    end

endmodule // ofs_plat_afu

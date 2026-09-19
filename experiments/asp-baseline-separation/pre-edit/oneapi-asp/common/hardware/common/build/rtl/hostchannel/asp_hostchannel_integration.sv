// SPDX-License-Identifier: MIT
`include "ofs_plat_if.vh"
// Source integration boundary: place between ofs_plat_afu's physical
// host_mem_to_afu[0]/mmio64_to_afu and the unchanged afu/VTP/DDR-DMA subtree.
// Streams are same-clock ready/valid. Do not connect a different kernel clock
// without a separately reset-coordinated asynchronous FIFO adapter.
module asp_hostchannel_integration #(
    parameter int FIFO_LOG_DEPTH = 6,
    parameter int BATCH_LINES = 32
)(
    ofs_plat_avalon_mem_rdwr_if.to_sink host_mem,
    ofs_plat_avalon_mem_rdwr_if.to_source legacy_host_mem,
    ofs_plat_avalon_mem_if.to_source mmio,
    ofs_plat_avalon_mem_if.to_sink legacy_mmio,
    output wire stream_clk,
    output wire stream_reset_n,
    output logic [511:0] host_to_kernel_data,
    output logic host_to_kernel_valid,
    input logic host_to_kernel_ready,
    input logic [511:0] kernel_to_host_data,
    input logic kernel_to_host_valid,
    output logic kernel_to_host_ready
);
    import asp_hostchannel_pkg::*;
    assign stream_clk = host_mem.clk;
    assign stream_reset_n = host_mem.reset_n;
    ofs_plat_avalon_mem_rdwr_if #(
        `OFS_PLAT_AVALON_MEM_RDWR_IF_REPLICATE_PARAMS(host_mem)
    ) channels[2]();
    for (genvar c = 0; c < 2; c = c + 1) begin : channel_clocks
        assign channels[c].clk = host_mem.clk;
        assign channels[c].reset_n = host_mem.reset_n;
        assign channels[c].instance_number = host_mem.instance_number + c + 1;
    end
    logic egress_idle, share_fault;
    asp_hostchannel_share sharing (
        .host_mem, .legacy(legacy_host_mem),
        .ingress(channels[0]), .egress(channels[1]), .egress_idle, .share_fault
    );

    logic [1:0] csr_write, csr_bad;
    logic [63:0] csr_data[2];
    wire [63:0] byte_address = 64'(mmio.address) << 3;
    wire selected = (byte_address >= MMIO_BASE) && (byte_address < MMIO_BASE + MMIO_SPAN);
    wire [63:0] offset = byte_address - MMIO_BASE;
    wire slot_valid = offset < (2 * SLOT_STRIDE);
    wire slot = offset[8];
    wire full_access = (&mmio.byteenable) && (mmio.burstcount == 1) && !(mmio.read && mmio.write);
    wire known_register = (offset[2:0] == 0) && (offset[7:0] <= CSR_ELEMENT_BYTES);
    logic read_busy, local_owner, local_valid;
    logic [63:0] local_data;
    logic [mmio.RESPONSE_WIDTH-1:0] local_response;
    logic [mmio.USER_WIDTH-1:0] local_user;
    wire accepted = (mmio.read || mmio.write) && !mmio.waitrequest;
    // One outstanding MMIO read makes response ownership explicit even when
    // switching between legacy and hostchannel windows. DMA itself is pipelined.
    assign mmio.waitrequest = !host_mem.reset_n || read_busy ||
                              (!selected && legacy_mmio.waitrequest);
    assign legacy_mmio.address = mmio.address;
    assign legacy_mmio.burstcount = mmio.burstcount;
    assign legacy_mmio.byteenable = mmio.byteenable;
    assign legacy_mmio.writedata = mmio.writedata;
    assign legacy_mmio.user = mmio.user;
    assign legacy_mmio.read = mmio.read && !selected && !read_busy && host_mem.reset_n;
    assign legacy_mmio.write = mmio.write && !selected && !read_busy && host_mem.reset_n;
    assign mmio.readdatavalid = local_owner ? local_valid : legacy_mmio.readdatavalid;
    assign mmio.readdata = local_owner ? local_data : legacy_mmio.readdata;
    assign mmio.response = local_owner ? local_response : legacy_mmio.response;
    assign mmio.readresponseuser = local_owner ? local_user : legacy_mmio.readresponseuser;
    // PIM MMIO writes are posted and do not require an AFU write response.
    // Preserve any optional legacy response rather than consuming it.
    assign mmio.writeresponsevalid = legacy_mmio.writeresponsevalid;
    assign mmio.writeresponse = legacy_mmio.writeresponse;
    assign mmio.writeresponseuser = legacy_mmio.writeresponseuser;
    always_comb begin
        csr_write = 0;
        csr_bad = 0;
        if (accepted && selected) begin
            if (slot_valid) begin
                csr_write[slot] = mmio.write && full_access;
                csr_bad[slot] = !full_access;
            end else if (mmio.write) begin
                // Reserved slots have no engine of their own: report malformed
                // writes in slot 0 rather than silently aliasing another slot.
                csr_bad[0] = 1;
            end
        end
    end
    always_ff @(posedge host_mem.clk) begin
        if (!host_mem.reset_n) begin
            read_busy <= 0; local_owner <= 0; local_valid <= 0;
            local_data <= 0; local_response <= 0; local_user <= 0;
        end else begin
            local_valid <= 0;
            if (read_busy && mmio.readdatavalid) begin
                read_busy <= 0;
                local_owner <= 0;
            end
            if (accepted && mmio.read) begin
                // The legacy ASP returns registered responses. Supporting a
                // combinational zero-latency slave here requires a skid stage.
                read_busy <= 1;
                local_owner <= selected;
                if (selected) begin
                    local_valid <= 1;
                    local_data <= (slot_valid && full_access && known_register) ? csr_data[slot] : 0;
                    local_response <= (slot_valid && full_access && known_register) ? 0 : 2;
                    local_user <= mmio.user;
                end
            end
        end
    end

    asp_hostchannel_engine #(.H2D(1), .FIFO_LOG_DEPTH(FIFO_LOG_DEPTH), .BATCH_LINES(BATCH_LINES)) ingress (
        .mem(channels[0]), .external_fault(share_fault), .transport_idle(),
        .csr_write(csr_write[0]), .csr_bad_access(csr_bad[0]),
        .csr_address(offset[7:0]), .csr_writedata(mmio.writedata), .csr_readdata(csr_data[0]),
        .kernel_in_data(512'b0), .kernel_in_valid(1'b0), .kernel_in_ready(),
        .kernel_out_data(host_to_kernel_data), .kernel_out_valid(host_to_kernel_valid),
        .kernel_out_ready(host_to_kernel_ready)
    );
    asp_hostchannel_engine #(.H2D(0), .FIFO_LOG_DEPTH(FIFO_LOG_DEPTH), .BATCH_LINES(BATCH_LINES)) egress (
        .mem(channels[1]), .external_fault(share_fault), .transport_idle(egress_idle),
        .csr_write(csr_write[1]), .csr_bad_access(csr_bad[1]),
        .csr_address(offset[7:0]), .csr_writedata(mmio.writedata), .csr_readdata(csr_data[1]),
        .kernel_in_data(kernel_to_host_data), .kernel_in_valid(kernel_to_host_valid),
        .kernel_in_ready(kernel_to_host_ready),
        .kernel_out_data(), .kernel_out_valid(), .kernel_out_ready(1'b0)
    );
    // synthesis translate_off
    initial begin
        if (mmio.DATA_WIDTH != 64 || mmio.WAIT_REQUEST_ALLOWANCE != 0)
            $fatal(1, "Hostchannel CSR bridge requires 64-bit allowance-zero MMIO");
    end
    // synthesis translate_on
endmodule

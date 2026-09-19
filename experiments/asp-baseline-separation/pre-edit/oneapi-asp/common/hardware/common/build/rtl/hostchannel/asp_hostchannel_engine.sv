// SPDX-License-Identifier: MIT
`include "ofs_plat_if.vh"
// One DMA-backed channel. H2D=1: host ring -> kernel; H2D=0: kernel -> ring.
// mem uses physical line addresses, 512-bit data, waitrequestAllowance=0.
// Stream and CSR ports MUST be synchronous to mem.clk, readyLatency=0.
module asp_hostchannel_engine #(
    parameter bit H2D = 1,
    parameter int FIFO_LOG_DEPTH = 6,
    parameter int BATCH_LINES = 32
)(
    ofs_plat_avalon_mem_rdwr_if.to_sink mem,
    input logic external_fault,
    output logic transport_idle,
    input logic csr_write,
    input logic csr_bad_access,
    input logic [7:0] csr_address,
    input logic [63:0] csr_writedata,
    output logic [63:0] csr_readdata,
    input logic [511:0] kernel_in_data,
    input logic kernel_in_valid,
    output logic kernel_in_ready,
    output logic [511:0] kernel_out_data,
    output logic kernel_out_valid,
    input logic kernel_out_ready
);
    import asp_hostchannel_pkg::*;
    localparam int DEPTH = 1 << FIFO_LOG_DEPTH;
    wire clk = mem.clk;
    wire reset_n = mem.reset_n;
    logic run, quiesce, clean_epoch;
    logic [63:0] ring_iova, ring_bytes, host_position, device_position;
    logic [63:0] error_bits, csr_errors, dma_errors;
    logic dma_idle, transport_poison;
    assign transport_idle = dma_idle;
    wire quiesced = (!run || quiesce || (error_bits != 0)) &&
                     dma_idle && !transport_poison;
    wire active = run && !quiesce && (error_bits == 0);
    wire reset_positions = csr_write && !csr_bad_access &&
        (csr_address == CSR_CONTROL) && csr_writedata[2] &&
        !csr_writedata[0] && (csr_writedata[63:3] == 0) && quiesced;
    // Check upper physical address bits before conversion to line address.
    wire [63:0] ring_last = ring_iova + ring_bytes - 1'b1;
    wire valid_config = (ring_iova[5:0] == 0) &&
        (ring_bytes >= 64) && (ring_bytes <= 64'h80000000) &&
        ((ring_bytes & (ring_bytes - 1'b1)) == 0) &&
        (ring_last >= ring_iova) &&
        ((ring_last >> (mem.ADDR_WIDTH + 6)) == 0);
    wire configuration_idle = quiesced && clean_epoch && (host_position == 0) &&
                              (device_position == 0);
    logic host_update_ok;
    always_comb begin
        if (H2D)
            host_update_ok = (csr_writedata >= host_position) &&
                (csr_writedata >= device_position) &&
                (csr_writedata - device_position <= ring_bytes);
        else
            host_update_ok = (csr_writedata >= host_position) &&
                (csr_writedata <= device_position);
        host_update_ok = host_update_ok && (csr_writedata[5:0] == 0);
        csr_errors = 0;
        if (csr_bad_access) csr_errors = ERR_CSR;
        else if (csr_write) begin
            case (csr_address)
                CSR_CONTROL: begin
                    if (csr_writedata[63:3] != 0 ||
                        (csr_writedata[2] && (!quiesced || csr_writedata[0])))
                        csr_errors = ERR_CSR;
                    else if (csr_writedata[0] && !csr_writedata[1] && !valid_config)
                        csr_errors = ERR_CONFIG;
                end
                CSR_RING_IOVA, CSR_RING_BYTES:
                    if (!configuration_idle) csr_errors = ERR_CONFIG;
                CSR_HOST_POSITION:
                    if (!valid_config || !host_update_ok) csr_errors = ERR_POSITION;
                default: csr_errors = ERR_CSR;
            endcase
        end
        csr_readdata = 0;
        case (csr_address)
            CSR_IDENT: csr_readdata = ABI_IDENT;
            CSR_CONTROL: csr_readdata = {62'b0, quiesce, run};
            CSR_STATUS: csr_readdata = {61'b0, (error_bits != 0), quiesced, active};
            CSR_RING_IOVA: csr_readdata = ring_iova;
            CSR_RING_BYTES: csr_readdata = ring_bytes;
            CSR_HOST_POSITION: csr_readdata = host_position;
            CSR_DEVICE_POSITION: csr_readdata = device_position;
            CSR_ERROR: csr_readdata = error_bits;
            CSR_ELEMENT_BYTES: csr_readdata = ELEMENT_BYTES;
            default: csr_readdata = 0;
        endcase
    end
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            run <= 0; quiesce <= 1; clean_epoch <= 1;
            ring_iova <= 0; ring_bytes <= 0; host_position <= 0;
            error_bits <= 0;
        end else if (reset_positions) begin
            run <= 0; quiesce <= 1; clean_epoch <= 1; host_position <= 0; error_bits <= 0;
        end else begin
            error_bits <= error_bits | csr_errors | dma_errors;
            if (csr_write && !csr_bad_access && (csr_errors == 0)) begin
                case (csr_address)
                    CSR_CONTROL: begin
                        run <= csr_writedata[0]; quiesce <= csr_writedata[1];
                        if (csr_writedata[0]) clean_epoch <= 0;
                    end
                    CSR_RING_IOVA: ring_iova <= csr_writedata;
                    CSR_RING_BYTES: ring_bytes <= csr_writedata;
                    CSR_HOST_POSITION: host_position <= csr_writedata;
                    default: ;
                endcase
            end
        end
    end

    logic [511:0] fifo_in, fifo_out;
    logic fifo_in_valid, fifo_in_ready, fifo_out_valid, fifo_out_ready;
    logic [FIFO_LOG_DEPTH:0] fifo_count;
    asp_hostchannel_fifo #(.LOG_DEPTH(FIFO_LOG_DEPTH)) fifo (
        .clk, .reset_n, .clear(reset_positions),
        .in_data(fifo_in), .in_valid(fifo_in_valid), .in_ready(fifo_in_ready),
        .out_data(fifo_out), .out_valid(fifo_out_valid), .out_ready(fifo_out_ready),
        .count(fifo_count)
    );

    // Both buses always have fully-defined request fields, even when idle.
    assign mem.rd_burstcount = 1;
    assign mem.rd_byteenable = '1;
    assign mem.rd_user = '0;
    assign mem.wr_burstcount = 1;
    assign mem.wr_byteenable = '1;

    generate if (H2D) begin : ingress
        logic request_pending;
        logic [63:0] issued_position;
        logic [mem.ADDR_WIDTH-1:0] request_address;
        logic [FIFO_LOG_DEPTH:0] outstanding;
        wire fire = request_pending && !mem.rd_waitrequest;
        wire response = mem.rd_readdatavalid;
        wire expected_response = (outstanding != 0) || fire;
        wire pop = fifo_out_valid && fifo_out_ready;
        wire [63:0] next_issued = issued_position + (fire ? 64 : 0);
        // A response moves one reservation into the FIFO and does not release
        // capacity. Only kernel consumption releases a reservation.
        wire [FIFO_LOG_DEPTH+1:0] reserved_after =
            {1'b0, fifo_count} + {1'b0, outstanding} + (fire ? 1 : 0) - (pop ? 1 : 0);
        assign mem.rd_read = request_pending;
        assign mem.rd_address = request_address;
        assign mem.wr_write = 0;
        assign mem.wr_address = 0;
        assign mem.wr_writedata = 0;
        assign mem.wr_user = 0;
        assign kernel_in_ready = 0;
        assign kernel_out_data = fifo_out;
        assign kernel_out_valid = fifo_out_valid && active;
        assign fifo_out_ready = kernel_out_ready && active;
        assign fifo_in = mem.rd_readdata;
        assign fifo_in_valid = response && expected_response &&
                               (mem.rd_response == 0) && (error_bits == 0);
        assign dma_idle = !request_pending && (outstanding == 0);
        always_comb begin
            dma_errors = external_fault ? ERR_PROTOCOL : 0;
            if (response && mem.rd_response != 0) dma_errors = dma_errors | ERR_RESPONSE;
            if ((response && !expected_response) || mem.wr_writeresponsevalid ||
                (fifo_in_valid && !fifo_in_ready)) dma_errors = dma_errors | ERR_PROTOCOL;
        end
        always_ff @(posedge clk) begin
            if (!reset_n || reset_positions) begin
                request_pending <= 0; request_address <= 0;
                issued_position <= 0; device_position <= 0; outstanding <= 0;
                transport_poison <= 0;
            end else begin
                if ((dma_errors & ERR_PROTOCOL) != 0) transport_poison <= 1;
                if (fire) issued_position <= issued_position + 64;
                case ({fire, response && expected_response})
                    2'b10: outstanding <= outstanding + 1'b1;
                    2'b01: outstanding <= outstanding - 1'b1;
                    default: ;
                endcase
                if (fifo_in_valid && fifo_in_ready)
                    device_position <= device_position + 64;
                // Once presented, a request remains stable through backpressure,
                // including a concurrent software quiesce/error transition.
                if (!request_pending || fire) begin
                    request_pending <= 0;
                    if (active && csr_errors == 0 && dma_errors == 0 &&
                        !reset_positions && (reserved_after < DEPTH) &&
                        (next_issued < host_position)) begin
                        request_pending <= 1;
                        request_address <= (ring_iova +
                            (next_issued & (ring_bytes - 1'b1))) >> 6;
                    end
                end
            end
        end
    end else begin : egress
        typedef enum logic [1:0] {PAYLOAD, DRAIN, FENCE_REQUEST, FENCE_WAIT} state_t;
        state_t state;
        logic request_pending;
        logic [63:0] issued_position;
        logic [31:0] outstanding, batch_count;
        wire payload_fire = (state == PAYLOAD) && request_pending && !mem.wr_waitrequest;
        wire fence_fire = (state == FENCE_REQUEST) && !mem.wr_waitrequest;
        wire normal_response = mem.wr_writeresponsevalid &&
            ((state == PAYLOAD) || (state == DRAIN));
        wire expected_normal = (outstanding != 0) || payload_fire;
        wire fence_response = mem.wr_writeresponsevalid &&
            ((state == FENCE_WAIT) || fence_fire);
        wire [63:0] next_issued = issued_position + (payload_fire ? 64 : 0);
        wire [63:0] used_after = next_issued - host_position;
        wire can_issue = active && csr_errors == 0 && dma_errors == 0 &&
            (fifo_count > (payload_fire ? 1 : 0)) &&
            (used_after < ring_bytes) && (next_issued <= 64'hffffffffffffffbf) &&
            (batch_count + (payload_fire ? 1 : 0) < BATCH_LINES);
        assign mem.rd_read = 0;
        assign mem.rd_address = 0;
        assign mem.wr_write = ((state == PAYLOAD) && request_pending) || (state == FENCE_REQUEST);
        assign mem.wr_address = (ring_iova + (issued_position & (ring_bytes - 1'b1))) >> 6;
        assign mem.wr_writedata = (state == FENCE_REQUEST) ? '0 : fifo_out;
        always_comb begin
            mem.wr_user = 0;
            mem.wr_user[ofs_plat_host_chan_avalon_mem_pkg::HC_AVALON_UFLAG_FENCE] =
                (state == FENCE_REQUEST);
        end
        assign fifo_in = kernel_in_data;
        assign fifo_in_valid = kernel_in_valid && active;
        assign kernel_in_ready = fifo_in_ready && active;
        assign kernel_out_data = 0;
        assign kernel_out_valid = 0;
        assign fifo_out_ready = payload_fire;
        assign dma_idle = (state == PAYLOAD) && !request_pending &&
                          (outstanding == 0) && (batch_count == 0);
        always_comb begin
            dma_errors = external_fault ? ERR_PROTOCOL : 0;
            if (mem.wr_writeresponsevalid && mem.wr_response != 0)
                dma_errors = dma_errors | ERR_RESPONSE;
            if (mem.rd_readdatavalid ||
                (normal_response && !expected_normal) ||
                (mem.wr_writeresponsevalid && !normal_response && !fence_response))
                dma_errors = dma_errors | ERR_PROTOCOL;
            if (active && fifo_out_valid && next_issued > 64'hffffffffffffffbf)
                dma_errors = dma_errors | ERR_POSITION;
        end
        always_ff @(posedge clk) begin
            if (!reset_n || reset_positions) begin
                state <= PAYLOAD; request_pending <= 0;
                outstanding <= 0; batch_count <= 0;
                issued_position <= 0; device_position <= 0;
                transport_poison <= 0;
            end else begin
                if ((dma_errors & ERR_PROTOCOL) != 0 ||
                    (fence_response && mem.wr_response != 0)) transport_poison <= 1;
                case ({payload_fire, normal_response && expected_normal})
                    2'b10: outstanding <= outstanding + 1'b1;
                    2'b01: outstanding <= outstanding - 1'b1;
                    default: ;
                endcase
                if (payload_fire) begin
                    issued_position <= issued_position + 64;
                    batch_count <= batch_count + 1'b1;
                end
                case (state)
                    PAYLOAD: begin
                        if (!request_pending || payload_fire) request_pending <= can_issue;
                        // Force a fence at a bounded batch size, on stalls in
                        // the stream/ring, and on quiesce/error. Never cancel a
                        // pending payload to inject a fence.
                        if (!request_pending && batch_count != 0 && !can_issue)
                            state <= DRAIN;
                    end
                    DRAIN: if (outstanding == 0) state <= FENCE_REQUEST;
                    FENCE_REQUEST: if (fence_fire) state <= FENCE_WAIT;
                    FENCE_WAIT: ;
                    default: ;
                endcase
                if (fence_response) begin
                    // Only a successful fence is the host-visibility boundary.
                    if (mem.wr_response == 0 && error_bits == 0 && dma_errors == 0)
                        device_position <= issued_position;
                    state <= PAYLOAD;
                    batch_count <= 0;
                end
            end
        end
    end endgenerate

    // synthesis translate_off
    initial begin
        if (mem.DATA_WIDTH != 512 || mem.MASKED_SYMBOL_WIDTH != 8 ||
            mem.WAIT_REQUEST_ALLOWANCE != 0 || mem.ADDR_WIDTH > 58 ||
            FIFO_LOG_DEPTH < 1 || FIFO_LOG_DEPTH > 16 || BATCH_LINES < 1)
            $fatal(1, "Unsupported DMA hostchannel interface/parameters");
    end
    // synthesis translate_on
endmodule

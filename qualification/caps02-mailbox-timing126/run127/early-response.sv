`timescale 1ns/1ps
// New observer-only CDC. Does not drive/reset the memory controller or FIM.
// Bundled payloads stay fixed across the synchronized request/ack handshake.
// Physical use additionally requires reviewed CDC max-delay constraints.
module ia840f_ahls_observer_mailbox_timing126 #(
    parameter integer SNAP_BITS=768,
    parameter integer SEQ_BITS=64
)(
    input wire core_clk,core_reset_n,bank_clk,bank_reset_n,
    input wire core_cmd_valid,
    input wire [1:0] core_cmd,
    input wire [63:0] core_expected,core_token,
    input wire dma_write_attempt,
    input wire core_access_fault,
    output wire core_ready,
    output reg core_busy,core_valid,core_done,
    output reg [7:0] core_errors,
    output reg epoch_window,
    output wire [63:0] core_sequence,
    output reg [SNAP_BITS-1:0] core_snapshot,
    output reg response_armed,response_error,
    output wire bank_link_reset_n,
    output reg bank_cmd_valid,
    output wire [1:0] bank_cmd,
    output wire [63:0] bank_expected,bank_token,
    output wire bank_dma_fault,
    input wire bank_cmd_ack,
    input wire [SNAP_BITS-1:0] bank_snapshot,
    input wire bank_error,bank_armed
);
    wire common_reset_n=core_reset_n && bank_reset_n;
    (* async_reg="true" *) reg [1:0] core_reset_pipe,bank_reset_pipe;
    wire core_link_reset_n=core_reset_pipe[1];
    always @(posedge core_clk or negedge common_reset_n)
        if(!common_reset_n) core_reset_pipe<=0;
        else core_reset_pipe<={core_reset_pipe[0],1'b1};
    always @(posedge bank_clk or negedge common_reset_n)
        if(!common_reset_n) bank_reset_pipe<=0;
        else bank_reset_pipe<={bank_reset_pipe[0],1'b1};
    assign bank_link_reset_n=bank_reset_pipe[1];

    reg request_toggle,ack_toggle;
    // Install a held payload first; publish its notification on the next local edge.
    reg request_pending,response_pending;
    reg [129:0] request_hold;
    reg [129:0] bank_request;
    reg [SNAP_BITS-1:0] response_hold;
    reg return_armed,return_error;
    reg waiting_bank_ack;
    (* async_reg="true" *) reg [1:0] ack_sync,bank_up_sync,bank_error_sync;
    (* async_reg="true" *) reg [1:0] request_sync,dma_fault_sync;
    reg dma_fault_sticky;
    reg [SEQ_BITS-1:0] sequence_counter;
    localparam [SEQ_BITS-1:0] SEQ_MAX={SEQ_BITS{1'b1}};
    wire sequence_full=(sequence_counter==SEQ_MAX);
    wire source_accept=core_cmd_valid && core_ready;
    wire source_complete=core_busy && !request_pending && core_link_reset_n && bank_up_sync[1] &&
                         (ack_sync[1]==request_toggle);
    wire dma_now=dma_write_attempt &&
                 (epoch_window || (source_accept && core_cmd==2'd1));
    wire source_reject=(core_cmd_valid && !core_ready) || core_access_fault;
    assign core_sequence=sequence_counter;
    assign core_ready=core_link_reset_n && bank_up_sync[1] && !core_busy &&
                      (core_errors==0) && !bank_error_sync[1];
    assign bank_cmd=bank_request[129:128];
    assign bank_expected=bank_request[127:64];
    assign bank_token=bank_request[63:0];
    assign bank_dma_fault=dma_fault_sync[1];
    initial begin
        if(SEQ_BITS<1 || SEQ_BITS>64 || SNAP_BITS<1)
            $fatal(1,"Unsupported mailbox geometry");
    end

    always @(posedge core_clk or negedge core_link_reset_n) begin
        if(!core_link_reset_n) begin
            ack_sync<=0;bank_up_sync<=0;bank_error_sync<=0;
        end else begin
            ack_sync<={ack_sync[0],ack_toggle};
            bank_up_sync<={bank_up_sync[0],bank_link_reset_n};
            bank_error_sync<={bank_error_sync[0],bank_error};
        end
    end
    always @(posedge bank_clk or negedge bank_link_reset_n) begin
        if(!bank_link_reset_n) begin request_sync<=0;dma_fault_sync<=0;end
        else begin
            request_sync<={request_sync[0],request_toggle};
            dma_fault_sync<={dma_fault_sync[0],dma_fault_sticky};
        end
    end

    // Epoch history survives a bank-only reset; mailbox validity does not.
    // The reset synchronizer stretches even a short bank reset for observation.
    always @(posedge core_clk or negedge core_reset_n) begin
        if(!core_reset_n) begin
            core_errors<=0;epoch_window<=0;dma_fault_sticky<=0;sequence_counter<=0;
        end else begin
            if(source_reject) core_errors[0]<=1;
            if(epoch_window && !core_link_reset_n) core_errors[1]<=1;
            if(dma_now) begin core_errors[2]<=1;dma_fault_sticky<=1;end
            if(bank_error_sync[1] || (source_complete && return_error)) core_errors[3]<=1;
            if(source_accept && core_cmd==2'd1) epoch_window<=1;
            if(source_complete) begin
                if(sequence_full) core_errors[4]<=1;
                else sequence_counter<=sequence_counter+1'b1;
                if(request_hold[129:128]==2'd3 && !return_armed && !return_error &&
                   core_errors==0 && !dma_now && !bank_error_sync[1] && !sequence_full && !source_reject)
                    epoch_window<=0;
            end
        end
    end

    // Request enqueue and result install never wait combinationally for bank_clk.
    always @(posedge core_clk or negedge core_link_reset_n) begin
        if(!core_link_reset_n) begin
            request_toggle<=0;request_pending<=0;request_hold<=0;core_busy<=0;core_valid<=0;core_done<=0;
            core_snapshot<=0;response_armed<=0;response_error<=0;
        end else begin
            core_done<=0;
            if(source_accept) begin
                request_hold<={core_cmd,core_expected,core_token};
                request_pending<=1;core_busy<=1;core_valid<=0;
            end
            if(request_pending) begin
                request_toggle<=~request_toggle;request_pending<=0;
            end
            if(source_complete) begin
                core_snapshot<=response_hold;
                response_armed<=return_armed;response_error<=return_error;
                core_busy<=0;core_done<=1;
                core_valid<=(core_errors==0) && !return_error &&
                            !bank_error_sync[1] && !sequence_full && !dma_now && !source_reject;
            end
            if(core_errors!=0 || bank_error_sync[1] || dma_now || source_reject)
                core_valid<=0;
        end
    end

    // One native command strobe. Snapshot is captured only after the observer's
    // registered acknowledgement, so command effects are included coherently.
    always @(posedge bank_clk or negedge bank_link_reset_n) begin
        if(!bank_link_reset_n) begin
            ack_toggle<=0;response_pending<=0;bank_request<=0;bank_cmd_valid<=0;waiting_bank_ack<=0;
            response_hold<=0;return_armed<=0;return_error<=0;
        end else begin
            bank_cmd_valid<=0;
            if(response_pending) begin
                ack_toggle<=request_sync[1];response_pending<=0;waiting_bank_ack<=0;
            end else if(!waiting_bank_ack && request_sync[1]!=ack_toggle) begin
                bank_request<=request_hold;bank_cmd_valid<=1;waiting_bank_ack<=1;
            end else if(waiting_bank_ack && bank_cmd_ack) begin
                response_hold<=bank_snapshot;return_armed<=bank_armed;return_error<=bank_error;
                ack_toggle<=request_sync[1];response_pending<=1;
            end
        end
    end
endmodule

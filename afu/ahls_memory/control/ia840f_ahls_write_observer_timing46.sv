`timescale 1ns/1ps
// Additive candidate implementing OBSERVER-TIMING-DESIGN46.md.
// Passive native-bank accounting, not a publication/global-drain/reset fence.
// Stage A samples EVERY edge, including idle. Stage C commits that complete
// observation one edge later. Commands never flush younger observations.
// Public counters/flags/ack are all C state; private A values are not snapshots.
// No timing or physical CDC acceptance is implied. Keep PUBLISH_SUPPORTED=0.
module ia840f_ahls_write_observer_timing46 #(
    parameter integer COUNTER_BITS=64
)(
    input wire clk, rst_n,
    input wire awvalid, awready,
    input wire [7:0] awlen,
    input wire [8:0] awid,
    input wire wvalid, wready, wlast,
    input wire [63:0] wstrb,
    input wire bvalid, bready,
    input wire [1:0] bresp,
    input wire [8:0] bid,
    input wire cmd_valid,
    input wire [1:0] cmd,
    input wire [63:0] cmd_expected, cmd_token,
    input wire dma_write_fault, link_fault,
    output reg cmd_ack,
    output reg armed,
    output reg empty, target_retired,
    output reg [7:0] errors,
    output reg [63:0] first_error, token, expected_bytes, baseline,
    output wire [63:0] aw_total, b_total, expected_w_beats,
    output wire [63:0] w_total, wlast_total, accepted_bytes, retired_bytes
);
    localparam [63:0] COUNT_MAX=64'hffffffffffffffff >> (64-COUNTER_BITS);
    localparam [COUNTER_BITS-1:0] SAT_MAX={COUNTER_BITS{1'b1}};
    initial begin
        if(COUNTER_BITS<8 || COUNTER_BITS>64)
            $fatal(1,"COUNTER_BITS must be 8..64");
    end

    // Explicitly sized unsigned balanced population tree, all 64 native lanes.
    wire [1:0] pc2 [0:31];
    wire [2:0] pc4 [0:15];
    wire [3:0] pc8 [0:7];
    wire [4:0] pc16 [0:3];
    wire [5:0] pc32 [0:1];
    wire [6:0] enabled;
    genvar g;
    generate
        for(g=0;g<32;g=g+1)begin: pop2
            assign pc2[g]={1'b0,wstrb[2*g]}+{1'b0,wstrb[2*g+1]};
        end
        for(g=0;g<16;g=g+1)begin: pop4
            assign pc4[g]={1'b0,pc2[2*g]}+{1'b0,pc2[2*g+1]};
        end
        for(g=0;g<8;g=g+1)begin: pop8
            assign pc8[g]={1'b0,pc4[2*g]}+{1'b0,pc4[2*g+1]};
        end
        for(g=0;g<4;g=g+1)begin: pop16
            assign pc16[g]={1'b0,pc8[2*g]}+{1'b0,pc8[2*g+1]};
        end
        for(g=0;g<2;g=g+1)begin: pop32
            assign pc32[g]={1'b0,pc16[2*g]}+{1'b0,pc16[2*g+1]};
        end
    endgenerate
    assign enabled={1'b0,pc32[0]}+{1'b0,pc32[1]};

    // A owns the six private saturating running totals and their aligned sidecar.
    reg [COUNTER_BITS-1:0] aA,bA,qA,wA,lA,tA;
    wire af=awvalid && awready;
    wire wf=wvalid && wready;
    wire bf=bvalid && bready;
    wire [8:0] aw_beats=af ? ({1'b0,awlen}+9'd1) : 9'd0;
    wire [6:0] w_bytes=wf ? enabled : 7'd0;
    wire [COUNTER_BITS:0] ax={1'b0,aA}+{{COUNTER_BITS{1'b0}},af};
    wire [COUNTER_BITS:0] bx={1'b0,bA}+{{COUNTER_BITS{1'b0}},bf};
    wire [COUNTER_BITS:0] qx={1'b0,qA}+{{(COUNTER_BITS-8){1'b0}},aw_beats};
    wire [COUNTER_BITS:0] wx={1'b0,wA}+{{COUNTER_BITS{1'b0}},wf};
    wire [COUNTER_BITS:0] lx={1'b0,lA}+{{COUNTER_BITS{1'b0}},(wf && wlast)};
    wire [COUNTER_BITS:0] tx={1'b0,tA}+{{(COUNTER_BITS-6){1'b0}},w_bytes};
    reg a_valid;
    reg [5:0] a_ov; // {A,B,Q,W,L,T}, from the SAME sample as A totals.
    reg a_af,a_bf,a_awvalid,a_wvalid,a_bvalid;
    reg [8:0] a_awid,a_bid;
    reg [1:0] a_bresp,a_cmd;
    reg a_cmd_valid,a_dma_fault,a_link_fault;
    reg [63:0] a_cmd_expected,a_cmd_token;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            aA<=0;bA<=0;qA<=0;wA<=0;lA<=0;tA<=0;
            a_valid<=0;a_ov<=0;a_af<=0;a_bf<=0;
            a_awvalid<=0;a_wvalid<=0;a_bvalid<=0;
            a_awid<=0;a_bid<=0;a_bresp<=0;
            a_cmd_valid<=0;a_cmd<=0;a_cmd_expected<=0;a_cmd_token<=0;
            a_dma_fault<=0;a_link_fault<=0;
        end else begin
            aA<=ax[COUNTER_BITS] ? SAT_MAX : ax[COUNTER_BITS-1:0];
            bA<=bx[COUNTER_BITS] ? SAT_MAX : bx[COUNTER_BITS-1:0];
            qA<=qx[COUNTER_BITS] ? SAT_MAX : qx[COUNTER_BITS-1:0];
            wA<=wx[COUNTER_BITS] ? SAT_MAX : wx[COUNTER_BITS-1:0];
            lA<=lx[COUNTER_BITS] ? SAT_MAX : lx[COUNTER_BITS-1:0];
            tA<=tx[COUNTER_BITS] ? SAT_MAX : tx[COUNTER_BITS-1:0];
            a_ov<={ax[COUNTER_BITS],bx[COUNTER_BITS],qx[COUNTER_BITS],
                   wx[COUNTER_BITS],lx[COUNTER_BITS],tx[COUNTER_BITS]};
            a_af<=af;a_bf<=bf;a_awvalid<=awvalid;a_wvalid<=wvalid;a_bvalid<=bvalid;
            a_awid<=awid;a_bid<=bid;a_bresp<=bresp;
            a_cmd_valid<=cmd_valid;a_cmd<=cmd;
            a_cmd_expected<=cmd_expected;a_cmd_token<=cmd_token;
            a_dma_fault<=dma_write_fault;a_link_fault<=link_fault;
            a_valid<=1;
        end
    end

    // Only these C mirrors drive the public cumulative counters.
    reg [COUNTER_BITS-1:0] pub_a,pub_b,pub_q,pub_w,pub_l,pub_t,c;
    assign aw_total={{(64-COUNTER_BITS){1'b0}},pub_a};
    assign b_total={{(64-COUNTER_BITS){1'b0}},pub_b};
    assign expected_w_beats={{(64-COUNTER_BITS){1'b0}},pub_q};
    assign w_total={{(64-COUNTER_BITS){1'b0}},pub_w};
    assign wlast_total={{(64-COUNTER_BITS){1'b0}},pub_l};
    assign accepted_bytes={{(64-COUNTER_BITS){1'b0}},pub_t};
    assign retired_bytes={{(64-COUNTER_BITS){1'b0}},c};
    reg [64:0] epoch_end65;

    // A/B/L increment by at most one; their overflowing raw value is 2**CB.
    // Reconstruct it rather than comparing saturation-equal values and losing
    // the higher-priority raw-credit fault on a B-only overflow observation.
    wire [COUNTER_BITS:0] raw_a=a_ov[5] ? {1'b1,{COUNTER_BITS{1'b0}}} : {1'b0,aA};
    wire [COUNTER_BITS:0] raw_b=a_ov[4] ? {1'b1,{COUNTER_BITS{1'b0}}} : {1'b0,bA};
    wire [COUNTER_BITS:0] raw_l=a_ov[1] ? {1'b1,{COUNTER_BITS{1'b0}}} : {1'b0,lA};
    wire [64:0] sample_t65={{(65-COUNTER_BITS){1'b0}},tA};
    wire empty_s=(aA==bA) && (qA==wA) && (lA==aA);
    wire raw_idle=!a_awvalid && !a_wvalid && !a_bvalid;
    reg [7:0] fault,en_pre,en_final;
    reg hit,armed_n,target_n;
    reg [63:0] first_n,token_n,expected_n,baseline_n;
    reg [64:0] end_n;
    reg [COUNTER_BITS-1:0] c_n;

    // Semantic logic consumes ONLY A register Q and previous committed state:
    // never ax/bx/.../tx, current VALID, current command or live fault payloads.
    always @* begin
        fault=0;
        fault[0]=a_bf && a_bresp!=2'b00;
        fault[1]=(a_af && a_awid!=0) || (a_bf && a_bid!=0);
        fault[2]=(raw_b>raw_a) || (raw_b>raw_l);
        fault[3]=|a_ov;
        fault[4]=armed && ((sample_t65<{1'b0,baseline}) || (sample_t65>epoch_end65));
        fault[5]=a_dma_fault && (armed || (a_cmd_valid && a_cmd==2'd1));
        fault[6]=a_link_fault;
        en_pre=errors | fault;
        // When empty and error-free the checkpoint becomes sample T, so no
        // checkpoint mux or baseline subtraction is needed in this predicate.
        hit=armed && en_pre==0 && empty_s &&
            sample_t65>={1'b0,baseline} && sample_t65==epoch_end65;
        armed_n=armed;token_n=token;expected_n=expected_bytes;
        baseline_n=baseline;end_n=epoch_end65;en_final=en_pre;
        if(a_cmd_valid) begin
            case(a_cmd)
                2'd1: begin
                    if(!armed && en_pre==0 && empty_s && raw_idle &&
                       a_cmd_expected!=0 && a_cmd_expected[1:0]==0 &&
                       a_cmd_expected<=64'h1fffffffc && a_cmd_expected<=COUNT_MAX &&
                       a_cmd_token!=0 && a_cmd_token!=token) begin
                        armed_n=1;token_n=a_cmd_token;expected_n=a_cmd_expected;
                        baseline_n=sample_t65[63:0];
                        // Keep carry even for CB=64. No new endpoint admission
                        // rejection: an unreachable future target faults on overflow.
                        end_n=sample_t65+{1'b0,a_cmd_expected};
                    end else en_final[7]=1;
                end
                2'd2: begin end
                2'd3: begin
                    if(hit && raw_idle) armed_n=0;
                    else en_final[7]=1;
                end
                default: en_final[7]=1;
            endcase
        end
        c_n=(empty_s && en_final==0) ? tA : c;
        target_n=hit && armed_n && en_final==0;
        first_n=first_error;
        if(!first_error[63] && en_final!=0) begin
            first_n=64'h8000000000000000;
            // Lowest code only WITHIN the first faulty observation. Subsequent
            // observations never replace an already latched first-error word.
            if(en_final[0]) begin
                first_n[7:0]=8'd1;first_n[9:8]=a_bresp;first_n[18:10]=a_bid;
            end else if(en_final[1]) begin
                first_n[7:0]=8'd2;
                first_n[18:10]=(a_af && a_awid!=0) ? a_awid : a_bid;
            end else if(en_final[2]) first_n[7:0]=8'd3;
            else if(en_final[3]) first_n[7:0]=8'd4;
            else if(en_final[4]) first_n[7:0]=8'd5;
            else if(en_final[5]) first_n[7:0]=8'd6;
            else if(en_final[6]) first_n[7:0]=8'd7;
            else first_n[7:0]=8'd8;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pub_a<=0;pub_b<=0;pub_q<=0;pub_w<=0;pub_l<=0;pub_t<=0;c<=0;
            errors<=0;first_error<=0;armed<=0;token<=0;
            expected_bytes<=0;baseline<=0;epoch_end65<=0;
            empty<=1;target_retired<=0;cmd_ack<=0;
        end else begin
            cmd_ack<=a_valid && a_cmd_valid;
            if(a_valid) begin
                pub_a<=aA;pub_b<=bA;pub_q<=qA;pub_w<=wA;pub_l<=lA;pub_t<=tA;
                c<=c_n;errors<=en_final;first_error<=first_n;
                armed<=armed_n;token<=token_n;expected_bytes<=expected_n;
                baseline<=baseline_n;epoch_end65<=end_n;
                empty<=empty_s;target_retired<=target_n;
            end
        end
    end
endmodule
